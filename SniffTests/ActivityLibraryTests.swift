import XCTest
import SwiftData
@testable import Sniff

@MainActor
final class ActivityLibraryTests: XCTestCase {
    func testSeedLibraryDecodesAndCoversBothSpecies() throws {
        let library = try ActivityLibrary(bundle: Bundle(for: ActivityLibraryTests.self))
        XCTAssertFalse(library.activities.isEmpty)
        XCTAssertTrue(library.activities.contains { $0.species == .dog })
        XCTAssertTrue(library.activities.contains { $0.species == .cat })
        XCTAssertTrue(library.activities.allSatisfy { !$0.steps.isEmpty && !$0.safetyNotes.isEmpty })
        XCTAssertGreaterThan(library.activities.count, 150)
        XCTAssertEqual(Set(library.activities.map(\.id)).count, library.activities.count)
        XCTAssertGreaterThan(library.activities.filter { $0.id.hasPrefix("master-") && !$0.materials.isEmpty }.count, 150)
    }

    func testRandomCategoryPoolChangesActivityAndStaysSafe() throws {
        let library = try makeLibrary([activity("calm-a", .calming), activity("calm-b", .calming), activity("social", .social)])
        let pet = makePet()
        let next = library.randomActivity(for: pet, categories: [.calming], excluding: "calm-a")
        XCTAssertEqual(next?.id, "calm-b")
        XCTAssertEqual(next?.category, .calming)
    }

    func testSafetyFilterRejectsWrongSpeciesMissingMaterialsAndExclusions() throws {
        let data = Data("""
        [{"id":"safe","species":"dog","title":"Safe","category":"social","tier":1,"durationMinutes":3,"materials":[],"description":"d","whyItWorks":"w","steps":["s"],"safetyNotes":["n"],"ageBands":["adult"],"sizeBands":["medium"],"energyLevels":["medium"],"exclusions":[]},
        {"id":"guard","species":"dog","title":"Food","category":"foraging","tier":1,"durationMinutes":3,"materials":["treats"],"description":"d","whyItWorks":"w","steps":["s"],"safetyNotes":["n"],"ageBands":["adult"],"sizeBands":["medium"],"energyLevels":["medium"],"exclusions":["resource_guarding"]},
        {"id":"cat","species":"cat","title":"Cat","category":"social","tier":1,"durationMinutes":3,"materials":[],"description":"d","whyItWorks":"w","steps":["s"],"safetyNotes":["n"],"ageBands":["adult"],"sizeBands":["medium"],"energyLevels":["medium"],"exclusions":[]}]
        """.utf8)
        let library = try ActivityLibrary(data: data)
        let pet = PetProfile(name: "Milo", species: .dog, age: .adult, size: .medium, energy: .medium, limitations: [.resourceGuarding], materials: [.treats])
        XCTAssertEqual(library.safeActivities(for: pet).map(\.id), ["safe"])
    }

    func testRecommendationNeverReturnsUnsafeActivity() throws {
        let library = try ActivityLibrary(bundle: Bundle(for: ActivityLibraryTests.self))
        let pet = PetProfile(name: "Luna", species: .cat, age: .senior, size: .small, energy: .low, limitations: [.foodAllergy, .mobilityLimited], materials: [])
        let recommendation = library.recommendation(for: pet)
        XCTAssertNotNil(recommendation)
        XCTAssertEqual(recommendation?.species, .cat)
        XCTAssertTrue(recommendation?.materials.isEmpty == true)
        XCTAssertTrue(recommendation?.exclusions.allSatisfy { !pet.limitations.contains($0) } == true)
    }

    func testLovedReactionBoostsCategoryWithoutRepeatingRecentActivity() throws {
        let library = try makeLibrary([activity("forage-new", .foraging), activity("social", .social), activity("calm", .calming)])
        let pet = makePet()
        let history = [RecommendationSignal(activityID: "older-forage", category: .foraging, reaction: .loved, date: .now)]
        XCTAssertEqual(library.recommendation(for: pet, history: history)?.id, "forage-new")
    }

    func testNotInterestedReactionDownweightsCategory() throws {
        let library = try makeLibrary([activity("forage-new", .foraging), activity("social", .social)])
        let pet = makePet()
        let history = [RecommendationSignal(activityID: "older-forage", category: .foraging, reaction: .notInterested, date: .now)]
        XCTAssertEqual(library.recommendation(for: pet, history: history)?.id, "social")
    }

    func testCategoryRotationAndRecentActivityAvoidance() throws {
        let library = try makeLibrary([activity("forage", .foraging), activity("social", .social), activity("calm", .calming)])
        let pet = makePet()
        let history = [
            RecommendationSignal(activityID: "forage", category: .foraging, reaction: .fine, date: .now),
            RecommendationSignal(activityID: "other-social", category: .social, reaction: .fine, date: .now.addingTimeInterval(-60))
        ]
        XCTAssertEqual(library.recommendation(for: pet, history: history)?.id, "calm")
    }

    func testHighArousalCompletionBiasesTowardCalming() throws {
        let library = try makeLibrary([activity("social", .social), activity("calm", .calming)])
        let pet = makePet()
        let history = [RecommendationSignal(activityID: "old-physical", category: .physical, reaction: .fine, date: .now)]
        XCTAssertEqual(library.recommendation(for: pet, history: history)?.id, "calm")
    }

    func testSwappedActivityIsGentlySuppressed() throws {
        let library = try makeLibrary([activity("a", .social), activity("b", .cognitive)])
        let pet = makePet()
        XCTAssertEqual(library.recommendation(for: pet, swaps: [SwapSignal(activityID: "a", date: .now)])?.id, "b")
    }

    func testNotInterestedActivityIsDifferentNextTimeButCanReturnAfterCooldown() throws {
        let library = try makeLibrary([activity("a-slow-blink", .social), activity("z-other", .social)])
        let pet = makePet()
        let now = Date(timeIntervalSince1970: 2_000_000)
        let outcome = RecommendationSignal(activityID: "a-slow-blink", category: .social, reaction: .notInterested, date: now, presetDurationSeconds: 180, actualDurationSeconds: 10, earlyStopReason: .lostInterest)
        XCTAssertEqual(library.recommendation(for: pet, history: [outcome], day: now)?.id, "z-other")
        let afterCooldown = library.rankedRecommendations(for: pet, history: [outcome], day: now.addingTimeInterval(15 * 86_400))
        XCTAssertTrue(afterCooldown.contains { $0.id == "a-slow-blink" })
    }

    func testOwnerStoppedDoesNotPenalizeActivity() throws {
        let library = try makeLibrary([activity("a-preferred", .social), activity("z-other", .cognitive)])
        let pet = makePet()
        let now = Date(timeIntervalSince1970: 2_000_000)
        let outcome = RecommendationSignal(activityID: "a-preferred", category: .social, reaction: .notInterested, date: now, presetDurationSeconds: 300, actualDurationSeconds: 10, earlyStopReason: .ownerStopped)
        XCTAssertEqual(library.recommendation(for: pet, history: [outcome], preferredCategories: [.social], day: now)?.id, "a-preferred")
    }

    func testMoodAndAvailableTimeShapeRanking() throws {
        let library = try makeLibrary([activity("calm-short", .calming, minutes: 3), activity("physical-short", .physical, minutes: 3), activity("calm-long", .calming, minutes: 10)])
        let pet = makePet()
        XCTAssertEqual(library.recommendation(for: pet, preferredCategories: [.calming], maximumMinutes: 5)?.id, "calm-short")
    }

    func testMoodSelectionRestrictsResultsWhenMatchingActivitiesExist() throws {
        let library = try makeLibrary([
            activity("physical-favorite", .physical, minutes: 3),
            activity("rainy-sensory", .sensory, minutes: 3),
            activity("tired-calm", .calming, minutes: 3)
        ])
        let pet = makePet()
        let history = [RecommendationSignal(activityID: "older-physical", category: .physical, reaction: .loved, date: .now)]
        let results = library.rankedRecommendations(for: pet, history: history, preferredCategories: [.calming, .sensory], maximumMinutes: 5)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { [.calming, .sensory].contains($0.category) })
    }

    func testPrimaryMoodRanksAheadOfSecondaryEnvironment() throws {
        let library = try makeLibrary([
            activity("rainy-cognitive", .cognitive, minutes: 3),
            activity("tired-calm", .calming, minutes: 3)
        ])
        let pet = makePet()
        let results = library.rankedRecommendations(for: pet, preferredCategories: [.calming, .cognitive], maximumMinutes: 5)
        XCTAssertEqual(results.first?.id, "tired-calm")
    }

    func testTimeOfDayCategoriesChangeRecommendation() throws {
        let library = try makeLibrary([
            activity("morning-move", .physical, minutes: 3),
            activity("evening-settle", .calming, minutes: 3)
        ])
        let pet = makePet()
        XCTAssertEqual(library.recommendation(for: pet, preferredCategories: DayPeriod.morning.categories, maximumMinutes: 5)?.id, "morning-move")
        XCTAssertEqual(library.recommendation(for: pet, preferredCategories: DayPeriod.evening.categories, maximumMinutes: 5)?.id, "evening-settle")
    }

    func testDayPeriodUsesClockHour() {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let morning = calendar.date(from: DateComponents(year: 2026, month: 8, day: 6, hour: 8))!
        let evening = calendar.date(from: DateComponents(year: 2026, month: 8, day: 6, hour: 19))!
        XCTAssertEqual(DayPeriod.current(at: morning, calendar: calendar), .morning)
        XCTAssertEqual(DayPeriod.current(at: evening, calendar: calendar), .evening)
    }

    func testFoodActivitiesAreExcludedWhenOnboardingDisallowsFoodEnrichment() throws {
        let library = try makeLibrary([
            activity("treat-search", .foraging, minutes: 3, materials: [.treats]),
            activity("box-search", .sensory, minutes: 3)
        ])
        let pet = makePet(materials: [.treats]); pet.foodEnrichmentAllowed = false
        XCTAssertEqual(library.safeActivities(for: pet).map(\.id), ["box-search"])
    }

    func testMealProximityUsesSavedSchedule() {
        let pet = makePet(); pet.firstMealHour = 8; pet.lastMealHour = 18
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let nearBreakfast = calendar.date(from: DateComponents(year: 2026, month: 8, day: 6, hour: 9))!
        let midday = calendar.date(from: DateComponents(year: 2026, month: 8, day: 6, hour: 13))!
        XCTAssertTrue(pet.isNearMeal(at: nearBreakfast, calendar: calendar))
        XCTAssertFalse(pet.isNearMeal(at: midday, calendar: calendar))
    }

    func testSnackActivitiesAreExcludedWhenPetHasNoSnacks() throws {
        let library = try makeLibrary([
            activity("treat-puzzle", .foraging, minutes: 3, materials: [.treats]),
            activity("towel-search", .sensory, minutes: 3)
        ])
        let pet = makePet(materials: [.treats]); pet.hasSnacks = false
        XCTAssertEqual(library.safeActivities(for: pet).map(\.id), ["towel-search"])
    }

    func testProgressiveBadgesRewardBestWeekAndConsecutiveDaysPermanently() {
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1, hour: 12))!
        let history = (0..<7).map { day in
            RecommendationSignal(activityID: "play-\(day)", category: .social, reaction: .fine, date: calendar.date(byAdding: .day, value: day, to: start)!, presetDurationSeconds: 1_800, actualDurationSeconds: 1_800)
        }
        let tracks = AchievementEngine.tracks(history: history, calendar: calendar)
        let weekly = tracks.first { $0.id == "weekly-time" }
        let days = tracks.first { $0.id == "good-days" }
        XCTAssertEqual(weekly?.earnedLevel, "Three-Hour Teammates")
        XCTAssertEqual(weekly?.nextLevel, "Five-Hour Friends")
        XCTAssertEqual(days?.earnedLevel, "A Week of Play")
        XCTAssertEqual(days?.nextLevel, "Two Joyful Weeks")
    }

    func testPetHistoryIsIsolated() throws {
        let library = try makeLibrary([activity("forage", .foraging)])
        let first = makePet(name: "First")
        let second = makePet(name: "Second")
        let session = EnrichmentSession(activity: library.activities[0], pet: first, reaction: .loved)
        XCTAssertEqual(ActivityLibrary.history(for: first, sessions: [session]).count, 1)
        XCTAssertTrue(ActivityLibrary.history(for: second, sessions: [session]).isEmpty)
    }

    func testLibraryFiltersTimeCategoryAndMaterials() throws {
        let library = try makeLibrary([
            activity("short", .social, minutes: 3),
            activity("long", .social, minutes: 9),
            activity("food", .foraging, minutes: 3, materials: [.treats])
        ])
        let pet = makePet(materials: [])
        XCTAssertEqual(library.filteredActivities(for: pet, maximumMinutes: 5, category: .social).map(\.id), ["short"])
        XCTAssertFalse(library.filteredActivities(for: pet, availableMaterialsOnly: true).contains { $0.id == "food" })
        XCTAssertTrue(library.filteredActivities(for: pet, availableMaterialsOnly: false).contains { $0.id == "food" })
    }

    func testRoutineCareLikeCatalogItemsNeverAppearAsPlay() throws {
        let care = Activity(id: "dog-brush-and-paw-routine", species: .dog, title: "Brush and paw routine", category: .calming, tier: 1, durationMinutes: 5, materials: [.groomingBrush], description: "Routine coat care", whyItWorks: "Care", steps: ["Brush"], safetyNotes: ["Stop"], ageBands: [.adult], sizeBands: [.medium], energyLevels: [.medium], exclusions: [])
        let play = activity("sniff-game", .sensory, minutes: 5)
        let library = try makeLibrary([care, play])
        let pet = makePet(materials: [.groomingBrush])
        XCTAssertEqual(library.safeActivities(for: pet).map(\.id), ["sniff-game"])
        XCTAssertEqual(library.filteredActivities(for: pet, availableMaterialsOnly: false).map(\.id), ["sniff-game"])
    }

    func testFetchTreatsRenameRequestAsNamesNotAnActivity() {
        let pet = makePet(name: "Epstein")
        let reply = FetchAssistant().reply(
            to: "give a new name for epstein",
            pet: pet,
            candidates: [activity("random-activity", .social)]
        )
        XCTAssertNil(reply.activityID)
        XCTAssertTrue(reply.text.contains("fresh name for Epstein"))
        XCTAssertFalse(reply.text.contains("random-activity"))
    }

    func testFetchUnderstandsSynonymsForCalmingRequest() {
        let pet = makePet()
        let reply = FetchAssistant().reply(
            to: "He seems overwhelmed and needs something soothing before bedtime",
            pet: pet,
            candidates: [activity("fast-chase", .physical), activity("quiet-reset", .calming)]
        )
        XCTAssertEqual(reply.activityID, "quiet-reset")
    }

    func testFetchUnderstandsTimeConstraint() {
        let pet = makePet()
        let reply = FetchAssistant().reply(
            to: "I only have five minutes",
            pet: pet,
            candidates: [activity("long-game", .social, minutes: 15), activity("short-game", .social, minutes: 5)]
        )
        XCTAssertEqual(reply.activityID, "short-game")
    }

    func testFetchCanAnswerProfileQuestionWithoutChoosingActivity() {
        let pet = makePet(name: "Milo", materials: [.towel])
        let reply = FetchAssistant().reply(to: "What do you know about Milo?", pet: pet, candidates: [])
        XCTAssertNil(reply.activityID)
        XCTAssertTrue(reply.text.contains("medium energy"))
        XCTAssertTrue(reply.text.contains("Towel"))
    }

    func testMaterialFreeActivitySkipsSetup() {
        XCTAssertFalse(activity("together", .social).needsSetup)
        XCTAssertTrue(activity("towel-search", .sensory, materials: [.towel]).needsSetup)
    }

    func testRestingGuidanceProtectsSleep() {
        XCTAssertTrue(PlayIntent.resting.guidance(for: .cat).localizedCaseInsensitiveContains("let them rest"))
        XCTAssertTrue(PlayIntent.resting.guidance(for: .dog).localizedCaseInsensitiveContains("sleeping dog rest"))
    }

    func testMaterialsDoNotOutrankAnEquivalentSimpleActivity() throws {
        let simple = activity("simple-bond", .social)
        let propBased = activity("prop-bond", .social, materials: [.towel])
        let library = try makeLibrary([propBased, simple])
        let pet = makePet(materials: [.towel])
        XCTAssertEqual(library.rankedRecommendations(for: pet, preferredCategories: [.social]).first?.id, simple.id)
    }

    private func makePet(name: String = "Milo", materials: Set<Material> = []) -> PetProfile {
        PetProfile(name: name, species: .dog, age: .adult, size: .medium, energy: .medium, limitations: [], materials: materials)
    }

    private func activity(_ id: String, _ category: ActivityCategory, minutes: Int = 3, materials: [Material] = []) -> Activity {
        Activity(id: id, species: .dog, title: id, category: category, tier: 1, durationMinutes: minutes, materials: materials, description: "Description", whyItWorks: "Why", steps: ["Step"], safetyNotes: ["Supervise"], ageBands: [.adult], sizeBands: [.medium], energyLevels: [.medium], exclusions: [])
    }

    private func makeLibrary(_ activities: [Activity]) throws -> ActivityLibrary {
        try ActivityLibrary(data: JSONEncoder().encode(activities))
    }
}
