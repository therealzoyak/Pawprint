import Foundation

enum ActivityLibraryError: Error { case missingResource }

struct ActivityLibrary {
    let activities: [Activity]

    init(bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "activities", withExtension: "json") else { throw ActivityLibraryError.missingResource }
        activities = try JSONDecoder().decode([Activity].self, from: Data(contentsOf: url))
    }
    init(data: Data) throws { activities = try JSONDecoder().decode([Activity].self, from: data) }

    static func history(for pet: PetProfile, sessions: [EnrichmentSession]) -> [RecommendationSignal] {
        sessions.filter { $0.petID == pet.id || ($0.petID == nil && $0.petName == pet.name) }.map {
            RecommendationSignal(activityID: $0.activityID, category: $0.category, reaction: $0.reaction, date: $0.completedAt, presetDurationSeconds: $0.presetDurationSeconds, actualDurationSeconds: $0.actualDurationSeconds, earlyStopReason: $0.earlyStopReason)
        }
    }

    static func swaps(for pet: PetProfile, events: [ActivitySwap]) -> [SwapSignal] {
        events.filter { $0.petID == pet.id }.map { SwapSignal(activityID: $0.activityID, date: $0.swappedAt) }
    }

    func safeActivities(for pet: PetProfile) -> [Activity] {
        activities.filter { activity in
            !activity.isRoutineCareLike && (!activity.usesFoodReward || pet.foodEnrichmentAllowed) && (!activity.usesSnackReward || pet.hasSnacks) &&
            activity.species == pet.species &&
            activity.ageBands.contains(pet.ageBand) &&
            activity.sizeBands.contains(pet.sizeBand) &&
            activity.energyLevels.contains(pet.energy) &&
            activity.exclusions.allSatisfy { !pet.limitations.contains($0) } &&
            Set(activity.materials).isSubset(of: pet.materials)
        }
    }

    func filteredActivities(for pet: PetProfile, maximumMinutes: Int? = nil, category: ActivityCategory? = nil, availableMaterialsOnly: Bool = true) -> [Activity] {
        activities.filter { activity in
            !activity.isRoutineCareLike && (!activity.usesFoodReward || pet.foodEnrichmentAllowed) && (!activity.usesSnackReward || pet.hasSnacks) && activity.species == pet.species && activity.ageBands.contains(pet.ageBand) &&
            activity.sizeBands.contains(pet.sizeBand) && activity.energyLevels.contains(pet.energy) &&
            activity.exclusions.allSatisfy { !pet.limitations.contains($0) } &&
            (!availableMaterialsOnly || Set(activity.materials).isSubset(of: pet.materials)) &&
            (maximumMinutes == nil || activity.durationMinutes <= maximumMinutes!) &&
            (category == nil || activity.category == category)
        }
    }

    func randomActivity(for pet: PetProfile, categories: [ActivityCategory], excluding activityID: String? = nil) -> Activity? {
        let safe = safeActivities(for: pet)
        let matching = safe.filter { categories.contains($0.category) }
        let pool = matching.isEmpty ? safe : matching
        let alternatives = pool.filter { $0.id != activityID }
        return alternatives.randomElement() ?? pool.randomElement()
    }

    func recommendation(for pet: PetProfile, history: [RecommendationSignal] = [], swaps: [SwapSignal] = [], favorites: Set<String> = [], preferredCategories: [ActivityCategory] = [], maximumMinutes: Int? = nil, day: Date = .now) -> Activity? {
        rankedRecommendations(for: pet, history: history, swaps: swaps, favorites: favorites, preferredCategories: preferredCategories, maximumMinutes: maximumMinutes, day: day).first
    }

    func rankedRecommendations(for pet: PetProfile, history: [RecommendationSignal] = [], swaps: [SwapSignal] = [], favorites: Set<String> = [], preferredCategories: [ActivityCategory] = [], maximumMinutes: Int? = nil, day: Date = .now) -> [Activity] {
        let safe = safeActivities(for: pet)
        guard !safe.isEmpty else { return [] }
        let calendar = Calendar.current
        let recentCutoff = calendar.date(byAdding: .day, value: -10, to: day) ?? day
        let retryCutoff = calendar.date(byAdding: .day, value: -14, to: day) ?? day
        let negativeActivityIDs = Set(history.filter {
            $0.date >= retryCutoff && $0.earlyStopReason != .ownerStopped &&
            ($0.reaction == .notInterested || $0.reaction == .tooHard || $0.earlyStopReason == .lostInterest || $0.earlyStopReason == .uncomfortable)
        }.map(\.activityID))
        let recentIDs = Set(history.filter { $0.date >= recentCutoff && $0.earlyStopReason != .ownerStopped && !favorites.contains($0.activityID) }.map(\.activityID))
        let recentSwapIDs = Set(swaps.filter { $0.date >= calendar.date(byAdding: .day, value: -2, to: day) ?? day }.map(\.activityID))
        let timeFits = safe.filter { maximumMinutes == nil || $0.durationMinutes <= maximumMinutes! }
        let timedPool = timeFits.isEmpty ? safe : timeFits
        let moodFits = timedPool.filter { preferredCategories.contains($0.category) }
        let contextualPool = preferredCategories.isEmpty || moodFits.isEmpty ? timedPool : moodFits
        var candidates = contextualPool.filter { !negativeActivityIDs.contains($0.id) && !recentIDs.contains($0.id) && !recentSwapIDs.contains($0.id) }
        if candidates.isEmpty { candidates = contextualPool.filter { !negativeActivityIDs.contains($0.id) && !recentSwapIDs.contains($0.id) } }
        if candidates.isEmpty { candidates = contextualPool.filter { !recentSwapIDs.contains($0.id) } }
        if candidates.isEmpty { candidates = contextualPool }

        let recentCategories = history.sorted { $0.date > $1.date }.prefix(2).map(\.category)
        let lastWasHighArousal = history.max(by: { $0.date < $1.date })?.category.isHighArousal == true
        let reactionWeights = Dictionary(grouping: history, by: \.category).mapValues { signals in
            signals.reduce(0) { score, signal in
                if signal.earlyStopReason == .ownerStopped { return score }
                return score + (signal.reaction == .loved ? 3 : signal.reaction == .tooHard ? -2 : signal.reaction == .notInterested ? -3 : 0)
            }
        }
        let dayNumber = calendar.ordinality(of: .day, in: .era, for: day) ?? 0
        return candidates.sorted { left, right in
            let leftScore = score(left), rightScore = score(right)
            return leftScore == rightScore ? left.id < right.id : leftScore > rightScore
        }

        func score(_ activity: Activity) -> Int {
            var value = reactionWeights[activity.category, default: 0] * 10
            if recentCategories.contains(activity.category) { value -= 16 }
            if lastWasHighArousal && activity.category == .calming { value += 30 }
            if favorites.contains(activity.id) { value += 4 }
            if let moodPriority = preferredCategories.firstIndex(of: activity.category) {
                value += max(28, 64 - moodPriority * 8)
            }
            if let maximumMinutes { value -= abs(activity.durationMinutes - maximumMinutes) * 3 }
            else {
                let playedToday = history.filter { calendar.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + max(0, $1.actualDurationSeconds / 60) }
                let usefulRemainingGoal = min(30, max(3, pet.dailyPlayGoalMinutes - playedToday))
                value -= abs(activity.durationMinutes - usefulRemainingGoal) * 2
            }
            let profileWords = "\(pet.temperamentNote) \(pet.sensitivityNote) \(pet.healthContextNote) \(pet.currentSituationNote)".lowercased()
            let expressedPreferences: [(ActivityCategory, [String])] = [
                (.calming, ["calm", "settle", "anxious", "nervous", "gentle", "quiet", "tired"]),
                (.physical, ["active", "playful", "zoom", "energy", "run", "move"]),
                (.cognitive, ["smart", "bored", "puzzle", "learn", "curious", "challenge"]),
                (.foraging, ["sniff", "food", "treat", "hungry", "search"]),
                (.social, ["cuddle", "bond", "together", "attention", "lonely"]),
                (.sensory, ["explore", "investigate", "texture", "sound", "novel"])
            ]
            for (category, words) in expressedPreferences where category == activity.category {
                value += words.filter(profileWords.contains).count * 18
            }
            if pet.recentPlayIntent?.categories.contains(activity.category) == true { value += 34 }
            if pet.preferredDayPeriods.contains(DayPeriod.current(at: day)) && DayPeriod.current(at: day).categories.contains(activity.category) { value += 16 }
            if pet.foodMotivation == .high && activity.category == .foraging { value += 14 }
            if pet.socialStyle == .interactive && activity.category == .social { value += 14 }
            if pet.noiseSensitive && activity.category == .calming { value += 18 }
            // Materials are available options, never an instruction to use every
            // object the owner happened to list. Prefer simpler starts when fit is equal.
            value -= activity.materials.count * 5
            if pet.recentPlayIntent == .resting && activity.materials.isEmpty { value += 28 }
            if pet.recentPlayIntent == .resting && activity.category == .social { value += 24 }

            for signal in history where signal.activityID == activity.id {
                if signal.earlyStopReason == .ownerStopped { continue }
                let age = max(0, calendar.dateComponents([.day], from: signal.date, to: day).day ?? 0)
                let decay = max(0, 14 - age)
                if signal.reaction == .notInterested { value -= 7 * decay }
                if signal.reaction == .tooHard { value -= 5 * decay }
                if signal.reaction == .loved { value += max(0, 8 - age) * 3 }
            }
            let meaningfulEarlyStops = history.filter {
                $0.actualDurationSeconds + 15 < $0.presetDurationSeconds &&
                ($0.earlyStopReason == .lostInterest || $0.earlyStopReason == .uncomfortable)
            }
            if meaningfulEarlyStops.count >= 2 {
                let learnedSeconds = meaningfulEarlyStops.suffix(5).map(\.actualDurationSeconds).reduce(0, +) / meaningfulEarlyStops.suffix(5).count
                value -= abs(activity.durationMinutes * 60 - learnedSeconds) / 12
                if meaningfulEarlyStops.filter({ $0.earlyStopReason == .uncomfortable }).count >= 2 && activity.category.isHighArousal { value -= 35 }
            }
            let relevantShortStops = history.filter {
                $0.category == activity.category && $0.actualDurationSeconds + 15 < $0.presetDurationSeconds &&
                $0.earlyStopReason != .ownerStopped && ($0.reaction == .notInterested || $0.earlyStopReason == .lostInterest || $0.earlyStopReason == .uncomfortable)
            }
            if !relevantShortStops.isEmpty {
                let target = relevantShortStops.suffix(5).map(\.actualDurationSeconds).reduce(0, +) / relevantShortStops.suffix(5).count
                value -= abs(activity.durationMinutes * 60 - target) / 20
                if activity.category == relevantShortStops.last?.category { value -= min(32, relevantShortStops.count * 10) }
            }
            value -= activity.tier * 2
            value += activity.id.unicodeScalars.reduce(dayNumber) { $0 + Int($1.value) } % 3
            return value
        }
    }
}
