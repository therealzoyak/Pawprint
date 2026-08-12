import Foundation
import SwiftData

enum Species: String, Codable, CaseIterable, Identifiable { case dog, cat; var id: Self { self } }
enum AgeBand: String, Codable, CaseIterable, Identifiable { case young, adult, senior; var id: Self { self } }
enum SizeBand: String, Codable, CaseIterable, Identifiable { case small, medium, large; var id: Self { self } }
enum EnergyLevel: String, Codable, CaseIterable, Identifiable { case low, medium, high; var id: Self { self } }
enum DayPeriod: String, Codable, CaseIterable, Identifiable {
    case morning, afternoon, evening, lateNight = "Late night"
    var id: Self { self }
    var label: String { rawValue.capitalized }
    var symbol: String { switch self { case .morning: "sunrise.fill"; case .afternoon: "sun.max.fill"; case .evening: "sunset.fill"; case .lateNight: "moon.stars.fill" } }
    var categories: [ActivityCategory] {
        switch self { case .morning: [.physical, .cognitive]; case .afternoon: [.social, .foraging, .sensory]; case .evening: [.sensory, .social, .calming]; case .lateNight: [.calming, .cognitive] }
    }
    static func current(at date: Date = .now, calendar: Calendar = .current) -> DayPeriod {
        switch calendar.component(.hour, from: date) { case 5..<12: .morning; case 12..<17: .afternoon; case 17..<22: .evening; default: .lateNight }
    }
}
enum FoodMotivation: String, Codable, CaseIterable, Identifiable { case low, medium, high; var id: Self { self }; var label: String { rawValue.capitalized } }
enum SocialStyle: String, Codable, CaseIterable, Identifiable {
    case independent, nearby, interactive
    var id: Self { self }
    var label: String { rawValue.capitalized }
}
enum DietStyle: String, Codable, CaseIterable, Identifiable {
    case dry, wet, mixed, fresh, prescription, other
    var id: Self { self }; var label: String { rawValue.capitalized }
}
enum LivingStyle: String, Codable, CaseIterable, Identifiable {
    case indoors, outdoors, both
    var id: Self { self }; var label: String { rawValue.capitalized }
}
enum Limitation: String, Codable, CaseIterable, Identifiable {
    case mobilityLimited = "mobility_limited", resourceGuarding = "resource_guarding", foodAllergy = "food_allergy", anxious, senior
    var id: Self { self }
    var label: String { rawValue.replacingOccurrences(of: "_", with: " ").capitalized }
}
enum Material: String, Codable, CaseIterable, Identifiable {
    case kibble, treats, towel, cardboard, muffinTin = "muffin_tin", cups, wandToy = "wand_toy", paperBag = "paper_bag", blanket, lickMat = "lick_mat"
    case fetchToy = "fetch_toy", lowObstacle = "low_obstacle", tugChaseToy = "tug_chase_toy", sprinkler
    case puzzleToy = "puzzle_toy", soundPlayer = "sound_player", calmingWearable = "calming_wearable"
    case catToy = "cat_toy", groomingBrush = "grooming_brush", cozyBedOrPerch = "cozy_bed_or_perch"
    case sock, emptyBottle = "empty_bottle", eggCarton = "egg_carton", toiletRoll = "toilet_roll", laundryBasket = "laundry_basket"
    case pillow, iceCubeTray = "ice_cube_tray", paper, woodenSpoon = "wooden_spoon", tennisBall = "tennis_ball"
    case squeakyToy = "squeaky_toy", chewToy = "chew_toy", tunnel, bells, featherToy = "feather_toy"
    var id: Self { self }
    var label: String {
        switch self {
        case .fetchToy: "Ball / Fetch Toy"
        case .lowObstacle: "Low Obstacle"
        case .tugChaseToy: "Tug / Chase Toy"
        case .puzzleToy: "Puzzle Feeder / Toy"
        case .soundPlayer: "Phone / Speaker"
        case .calmingWearable: "Calming Wrap / Vest"
        case .catToy: "Cat Chase / Kicker Toy"
        case .groomingBrush: "Grooming Brush"
        case .cozyBedOrPerch: "Cozy Bed / Perch"
        case .emptyBottle: "Empty Bottle"
        case .eggCarton: "Egg Carton"
        case .toiletRoll: "Paper Roll"
        case .laundryBasket: "Laundry Basket"
        case .iceCubeTray: "Ice Cube Tray"
        case .woodenSpoon: "Wooden Spoon"
        case .tennisBall: "Tennis Ball"
        case .squeakyToy: "Squeaky Toy"
        case .chewToy: "Chew Toy"
        case .featherToy: "Feather Toy"
        default: rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    var icon: String {
        switch self {
        case .kibble, .treats: "carrot.fill"
        case .towel, .blanket, .sock, .pillow: "square.grid.3x3.fill"
        case .cardboard, .eggCarton, .toiletRoll, .paperBag, .paper: "shippingbox.fill"
        case .muffinTin, .cups, .iceCubeTray: "circle.grid.3x3.fill"
        case .wandToy, .catToy, .featherToy: "wand.and.stars"
        case .fetchToy, .tennisBall: "circle.fill"
        case .tugChaseToy: "arrow.left.and.right"
        case .lickMat, .puzzleToy: "puzzlepiece.fill"
        case .cozyBedOrPerch: "house.fill"
        case .soundPlayer, .bells: "speaker.wave.2.fill"
        case .groomingBrush: "comb.fill"
        case .emptyBottle: "waterbottle.fill"
        case .laundryBasket: "basket.fill"
        case .woodenSpoon: "fork.knife"
        case .squeakyToy, .chewToy: "bone.fill"
        case .tunnel: "circle.dashed"
        case .lowObstacle: "figure.step.training"
        case .sprinkler: "drop.fill"
        case .calmingWearable: "tshirt.fill"
        }
    }
    var group: MaterialGroup {
        switch self {
        case .kibble, .treats, .lickMat: .snacks
        case .wandToy, .catToy, .fetchToy, .tugChaseToy, .puzzleToy, .tennisBall, .squeakyToy, .chewToy, .featherToy, .tunnel: .toys
        case .sock, .emptyBottle, .eggCarton, .toiletRoll, .paperBag, .paper, .woodenSpoon, .bells: .knickKnacks
        default: .household
        }
    }
    func fits(_ species: Species) -> Bool {
        switch self {
        case .wandToy, .catToy, .featherToy, .tunnel: species == .cat
        case .fetchToy, .tugChaseToy, .sprinkler, .tennisBall, .squeakyToy, .chewToy: species == .dog
        default: true
        }
    }
}
enum MaterialGroup: String, CaseIterable, Identifiable {
    case household = "Around the house", toys = "Favorite toys", snacks = "Treats & food", knickKnacks = "Little odd things"
    var id: Self { self }
    var colorName: String { rawValue }
}

enum PetContext: String, CaseIterable, Identifiable {
    case sleepy, curious, zoomies, hungry, cuddly, restless, distracted, anxious, playful, sniffy
    case hot, chilly, rainyDay, afterMeal, homeAlone, newToy, guestsOver, outdoorTime
    var id: Self { self }
    var icon: String {
        switch self {
        case .sleepy: "moon.zzz.fill"; case .curious: "eyes"; case .zoomies: "hare.fill"; case .hungry: "fork.knife"
        case .cuddly: "heart.fill"; case .restless: "arrow.triangle.2.circlepath"; case .distracted: "sparkle.magnifyingglass"
        case .anxious: "waveform.path.ecg"; case .playful: "figure.play"; case .sniffy: "nose"
        case .hot: "thermometer.sun.fill"; case .chilly: "thermometer.snowflake"; case .rainyDay: "cloud.rain.fill"
        case .afterMeal: "takeoutbag.and.cup.and.straw.fill"; case .homeAlone: "house.fill"; case .newToy: "gift.fill"
        case .guestsOver: "person.3.fill"; case .outdoorTime: "leaf.fill"
        }
    }
    func label(for species: Species) -> String {
        switch (species, self) {
        case (.cat, .zoomies): "3 a.m. zoomies"; case (.dog, .zoomies): "Full zoomies"
        case (.cat, .cuddly): "On my lap"; case (.dog, .cuddly): "Velcro mode"
        case (.cat, .restless): "Pacing the windows"; case (.dog, .restless): "Can’t settle"
        case (.cat, .playful): "Ready to pounce"; case (.dog, .playful): "Tail-wag playful"
        case (.cat, .sniffy): "Investigating"; case (.dog, .sniffy): "Nose-first"
        default: rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized
        }
    }
    var categories: [ActivityCategory] {
        switch self {
        case .sleepy, .anxious, .chilly, .afterMeal: [.calming]
        case .curious, .distracted, .newToy: [.cognitive, .sensory]
        case .zoomies, .restless, .playful, .outdoorTime: [.physical]
        case .hungry: [.foraging]
        case .cuddly, .homeAlone, .guestsOver: [.social]
        case .sniffy, .hot, .rainyDay: [.sensory, .cognitive]
        }
    }
    var isEnvironment: Bool { [.hot, .chilly, .rainyDay, .afterMeal, .homeAlone, .newToy, .guestsOver, .outdoorTime].contains(self) }
}
enum ActivityCategory: String, Codable, CaseIterable, Identifiable {
    case foraging, sensory, cognitive, physical, social, calming
    var id: Self { self }
    var isHighArousal: Bool { self == .physical }
}
enum Reaction: String, Codable, CaseIterable, Identifiable {
    case loved = "Loved it", fine = "Fine", tooHard = "Too hard", notInterested = "Not interested"
    var id: Self { self }
    var symbol: String { switch self { case .loved: "heart.fill"; case .fine: "hand.thumbsup.fill"; case .tooHard: "tortoise.fill"; case .notInterested: "minus.circle.fill" } }
}

enum EarlyStopReason: String, Codable, CaseIterable, Identifiable {
    case lostInterest = "Lost interest"
    case uncomfortable = "Seemed uncomfortable"
    case ownerStopped = "I needed to stop"
    case somethingElse = "Something else"
    var id: Self { self }
    var symbol: String {
        switch self {
        case .lostInterest: "eyes"
        case .uncomfortable: "heart.slash"
        case .ownerStopped: "clock.badge.xmark"
        case .somethingElse: "ellipsis.circle"
        }
    }
}

enum CareKind: String, Codable, CaseIterable, Identifiable {
    case feeding, water, brushing, bathing, coatCheck = "Coat check", pawCare = "Nails & paws", dentalCare = "Dental care", litterOrYard = "Litter / yard", medication, appointment, other
    var id: Self { self }
    var label: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .feeding: "fork.knife"
        case .water: "drop.fill"
        case .brushing: "comb.fill"
        case .bathing: "shower.fill"
        case .coatCheck: "magnifyingglass"
        case .pawCare: "pawprint.fill"
        case .dentalCare: "mouth.fill"
        case .medication: "pills.fill"
        case .litterOrYard: "leaf.fill"
        case .appointment: "calendar.badge.clock"
        case .other: "checkmark.circle.fill"
        }
    }
}

enum CareCadence: String, Codable, CaseIterable, Identifiable {
    case twiceDaily = "Twice daily", daily, everyOtherDay = "Every other day", twiceWeekly = "Twice weekly", weekly, biweekly = "Every two weeks", monthly, asNeeded = "As needed"
    var id: Self { self }
    var label: String { rawValue.capitalized }
}

enum EngagementLevel: Int, Codable, CaseIterable, Identifiable {
    case notFeelingIt = 1, curious, intoIt, excited, allIn
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .notFeelingIt: "Not feeling it"
        case .curious: "Curious"
        case .intoIt: "Into it"
        case .excited: "Excited"
        case .allIn: "All in"
        }
    }
    var symbol: String {
        switch self {
        case .notFeelingIt: "zzz"
        case .curious: "eyes"
        case .intoIt: "pawprint.fill"
        case .excited: "sparkles"
        case .allIn: "heart.fill"
        }
    }
}

enum PlayIntent: String, CaseIterable, Identifiable {
    case resting, curious, playful, hungry, seekingAttention, quietlyInterested
    var id: Self { self }
    var symbol: String {
        switch self { case .resting: "moon.zzz.fill"; case .curious: "eyes"; case .playful: "figure.play"; case .hungry: "fork.knife"; case .seekingAttention: "bell.fill"; case .quietlyInterested: "sparkles" }
    }
    var categories: [ActivityCategory] {
        switch self {
        case .resting: [.calming]
        case .curious: [.sensory, .cognitive]
        case .playful: [.physical]
        case .hungry: [.foraging]
        case .seekingAttention: [.social]
        case .quietlyInterested: [.cognitive, .sensory]
        }
    }
    func title(for species: Species) -> String {
        switch (species, self) {
        case (.cat, .resting): "Sleepy"
        case (.cat, .curious): "Curious"
        case (.cat, .playful): "Playful"
        case (.cat, .hungry): "Hungry"
        case (.cat, .seekingAttention): "Checking in with me"
        case (.cat, .quietlyInterested): "Secretly game"
        case (.dog, .resting): "Taking it easy"
        case (.dog, .curious): "Sniffy"
        case (.dog, .playful): "Playful"
        case (.dog, .hungry): "Treat-motivated"
        case (.dog, .seekingAttention): "Wants me"
        case (.dog, .quietlyInterested): "Needs a nudge"
        }
    }
    func hint(for species: Species) -> String {
        switch (species, self) {
        case (.cat, .resting): "Rest or gentle pets"
        case (.cat, .curious): "Join what I’m doing"
        case (.cat, .playful): "Toys, chase, pounce"
        case (.cat, .hungry): "Make food interesting"
        case (.cat, .seekingAttention): "Give me a job"
        case (.cat, .quietlyInterested): "Tempt me gently"
        case (.dog, .resting): "Keep it low-key"
        case (.dog, .curious): "Let me investigate"
        case (.dog, .playful): "Toys and movement"
        case (.dog, .hungry): "Turn snacks into play"
        case (.dog, .seekingAttention): "Do it together"
        case (.dog, .quietlyInterested): "Invite, don’t push"
        }
    }

    func guidance(for species: Species) -> String {
        switch (species, self) {
        case (.cat, .resting): "If your cat is asleep, let them sleep. Try this only after they wake and choose to engage."
        case (.dog, .resting): "Let a sleeping dog rest. When they wake, invite them gently and stop if they prefer downtime."
        case (_, .hungry): "Keep portions small, count food toward their daily meals, and stop if they become tense around food."
        case (.cat, _): "Invite—never chase or pick them up for play. Pause if their ears flatten, tail lashes, or they move away."
        case (.dog, _): "Start only if they choose to join. Pause for stiffness, repeated avoidance, or signs they need a break."
        }
    }
}

struct Activity: Codable, Identifiable, Hashable {
    let id: String
    let species: Species
    let title: String
    let category: ActivityCategory
    let tier: Int
    let durationMinutes: Int
    let materials: [Material]
    let description: String
    let whyItWorks: String
    let steps: [String]
    let safetyNotes: [String]
    let ageBands: [AgeBand]
    let sizeBands: [SizeBand]
    let energyLevels: [EnergyLevel]
    let exclusions: [Limitation]

    /// Material-free activities do not need a separate preparation flow.
    var needsSetup: Bool { !materials.isEmpty }

    /// Prefer artwork that depicts the actual game. The scene library uses the
    /// activity's props and setting before falling back to a category-fit scene.
    var artworkName: String {
        let visualClues = ([id, title] + materials.map(\.label))
            .joined(separator: " ")
            .lowercased()

        switch species {
        case .dog:
            if visualClues.containsAny(of: ["hurdle", "agility"]) { return "ActivityScene-dog-hurdle-beach" }
            if visualClues.containsAny(of: ["flirt pole", "flirt-pole"]) { return "ActivityScene-dog-flirt-home" }
            if visualClues.containsAny(of: ["tug", "rope"]) { return "ActivityScene-dog-tug-park" }
            if visualClues.containsAny(of: ["rubber bone", "bone dash"]) { return "ActivityScene-dog-bone-trail" }
            if visualClues.containsAny(of: ["stick", "obstacle"]) { return "ActivityScene-dog-obstacle-stick" }
            if visualClues.containsAny(of: ["sprinkler", "water play", "splash"]) { return "ActivityScene-dog-sprinkler-yard" }
            if visualClues.containsAny(of: ["frisbee", "flying disc", "disc flight"]) { return "ActivityScene-dog-frisbee-park" }
            if visualClues.containsAny(of: ["towel", "blanket fold", "snuffle"]) { return "ActivityScene-dog-towel-search" }
            if visualClues.containsAny(of: ["cardboard", "scent garden", "sniff box"]) { return "ActivityScene-dog-scent-box" }
            if visualClues.containsAny(of: ["cup", "which cup"]) { return "ActivityScene-dog-cup-choice" }
            if visualClues.containsAny(of: ["blanket", "settle", "quiet pause"]) { return "ActivityScene-dog-blanket-calm" }
            if visualClues.containsAny(of: ["ball", "fetch", "chase"]) { return "ActivityScene-dog-ball-park" }
            switch category {
            case .physical: return "ActivityScene-dog-ball-park"
            case .foraging: return "ActivityScene-dog-towel-search"
            case .sensory: return "ActivityScene-dog-scent-box"
            case .cognitive: return "ActivityScene-dog-cup-choice"
            case .social: return "ActivityScene-dog-tug-park"
            case .calming: return "ActivityScene-dog-blanket-calm"
            }
        case .cat:
            if visualClues.containsAny(of: ["wand", "feather", "flirt pole", "pounce"]) { return "ActivityScene-cat-wand" }
            if visualClues.containsAny(of: ["cardboard", "box", "lookout"]) { return "ActivityScene-cat-cardboard" }
            if visualClues.containsAny(of: ["cup", "shell game"]) { return "ActivityScene-cat-cup-puzzle" }
            if visualClues.containsAny(of: ["paper bag", "bag tunnel", "tunnel"]) { return "ActivityScene-cat-bag-tunnel" }
            if visualClues.containsAny(of: ["kibble", "food trail", "treat trail"]) { return "ActivityScene-cat-kibble-trail" }
            if visualClues.containsAny(of: ["blanket", "cave", "hideaway"]) { return "ActivityScene-cat-blanket-cave" }
            if visualClues.containsAny(of: ["paper", "crinkle", "rustle"]) { return "ActivityScene-cat-paper-rustle" }
            if visualClues.containsAny(of: ["slow blink", "slow-blink", "cheek rub", "together"]) { return "ActivityScene-cat-slow-blink" }
            if visualClues.containsAny(of: ["tower", "climb", "vertical"]) { return "ActivityScene-cat-tower-climb" }
            if visualClues.containsAny(of: ["shadow", "light watch", "sunbeam"]) { return "ActivityScene-cat-shadow-watch" }
            if visualClues.containsAny(of: ["window", "settle", "quiet pause"]) { return "ActivityScene-cat-window-calm" }
            if visualClues.containsAny(of: ["ball", "chase"]) { return "ActivityScene-cat-ball-hall" }
            switch category {
            case .physical: return "ActivityScene-cat-wand"
            case .foraging: return "ActivityScene-cat-kibble-trail"
            case .sensory: return "ActivityScene-cat-shadow-watch"
            case .cognitive: return "ActivityScene-cat-cup-puzzle"
            case .social: return "ActivityScene-cat-slow-blink"
            case .calming: return "ActivityScene-cat-window-calm"
            }
        }
    }

    /// Routine handling belongs in Care, even when an older catalog record was
    /// originally labeled as calming, sensory, or social enrichment.
    var isRoutineCareLike: Bool {
        if materials.contains(.groomingBrush) { return true }
        let text = "\(id) \(title) \(description)".lowercased()
        return ["coat care", "coat-care", "grooming consent", "brush consent", "brush choice",
                "paw routine", "wellness glance", "home care", "home-care"]
            .contains { text.contains($0) }
    }
    var usesFoodReward: Bool { materials.contains { [.kibble, .treats, .lickMat].contains($0) } }
    var usesSnackReward: Bool { materials.contains(.treats) }
    var displayTitle: String {
        let handTuned: [String: String] = [
            "dog-towel-search": "Towel Treasure Hunt",
            "dog-box-sniff": "Scent Garden",
            "dog-consent-check": "The Yes-or-No Game",
            "dog-cup-choice": "Pick a Cup",
            "dog-blanket-pause": "Cozy Reset",
            "cat-paper-rustle": "Paper Pounce",
            "cat-cardboard-lookout": "Box Lookout",
            "cat-slow-blink": "Slow-Blink Hello",
            "cat-kibble-trail": "Tiny Treasure Trail",
            "cat-blanket-hideaway": "Blanket Hideaway"
        ]
        if let tuned = handTuned[id] { return tuned }
        var cleaned = title
        for prefix in ["Local Park ", "Dog Park ", "Living Room ", "Hiking Trail ", "Obstacle Course ", "Backyard ", "Beach "] {
            if cleaned.hasPrefix(prefix) { cleaned.removeFirst(prefix.count); break }
        }
        cleaned = cleaned
            .replacingOccurrences(of: "Flirt Pole", with: "Flirt-Pole")
            .replacingOccurrences(of: "Hurdle Hop", with: "Happy Hurdles")
            .replacingOccurrences(of: "Bone Dash", with: "Toy Dash")
            .replacingOccurrences(of: "Sprinkler Zoomies", with: "Water Zoomies")
        return cleaned
    }
}

private extension String {
    func containsAny(of needles: [String]) -> Bool {
        needles.contains(where: contains)
    }
}

@Model final class LocalAccount {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date

    init(name: String) {
        self.name = name
        createdAt = .now
    }
}

@Model final class PetProfile {
    var id: UUID = UUID()
    var accountID: UUID?
    var ownerUID: String?
    var name: String
    var speciesRaw: String
    var ageRaw: String
    var sizeRaw: String
    var energyRaw: String
    var ageYears: Double?
    var weightPounds: Double?
    var breedGuess: String?
    @Attribute(.externalStorage) var avatarData: Data?
    var limitationRaws: [String]
    var materialRaws: [String]
    var createdAt: Date
    var profileUpdatedAt: Date = Date.now
    var temperamentNote: String = ""
    var sensitivityNote: String = ""
    var healthContextNote: String = ""
    var currentSituationNote: String = ""
    var lastPlayIntentRaw: String?
    var lastPlayContextAt: Date?
    var preferredDayPeriodRaws: [String] = []
    var foodMotivationRaw: String = FoodMotivation.medium.rawValue
    var socialStyleRaw: String = SocialStyle.nearby.rawValue
    var noiseSensitive: Bool = false
    var mealsPerDay: Int = 2
    var firstMealHour: Int = 8
    var lastMealHour: Int = 18
    var dietStyleRaw: String = DietStyle.mixed.rawValue
    var foodEnrichmentAllowed: Bool = true
    var hasSnacks: Bool = true
    var snacksPerDay: Int = 2
    var snackKinds: String = ""
    var wakeHour: Int = 7
    var sleepHour: Int = 22
    var hoursAloneDaily: Double = 2
    var livingStyleRaw: String = LivingStyle.indoors.rawValue
    var dailyPlayGoalMinutes: Int = 15

    init(name: String, species: Species, age: AgeBand, size: SizeBand, energy: EnergyLevel, exactAgeYears: Double? = nil, weightPounds: Double? = nil, breedGuess: String? = nil, limitations: Set<Limitation>, materials: Set<Material>, accountID: UUID? = nil, ownerUID: String? = nil) {
        self.name = name; speciesRaw = species.rawValue; ageRaw = age.rawValue; sizeRaw = size.rawValue; energyRaw = energy.rawValue
        self.ageYears = exactAgeYears; self.weightPounds = weightPounds; self.breedGuess = breedGuess
        limitationRaws = limitations.map(\.rawValue); materialRaws = materials.map(\.rawValue); self.accountID = accountID; self.ownerUID = ownerUID; createdAt = .now
    }
    var species: Species { Species(rawValue: speciesRaw) ?? .dog }
    var ageBand: AgeBand { AgeBand(rawValue: ageRaw) ?? .adult }
    var sizeBand: SizeBand { SizeBand(rawValue: sizeRaw) ?? .medium }
    var energy: EnergyLevel { EnergyLevel(rawValue: energyRaw) ?? .medium }
    var limitations: Set<Limitation> { Set(limitationRaws.compactMap(Limitation.init(rawValue:))) }
    var materials: Set<Material> { Set(materialRaws.compactMap(Material.init(rawValue:))) }
    var preferredDayPeriods: Set<DayPeriod> { Set(preferredDayPeriodRaws.compactMap(DayPeriod.init(rawValue:))) }
    var foodMotivation: FoodMotivation { FoodMotivation(rawValue: foodMotivationRaw) ?? .medium }
    var socialStyle: SocialStyle { SocialStyle(rawValue: socialStyleRaw) ?? .nearby }
    var dietStyle: DietStyle { DietStyle(rawValue: dietStyleRaw) ?? .mixed }
    var livingStyle: LivingStyle { LivingStyle(rawValue: livingStyleRaw) ?? .indoors }
    var recentPlayIntent: PlayIntent? {
        guard let lastPlayContextAt,
              lastPlayContextAt >= (Calendar.current.date(byAdding: .hour, value: -12, to: .now) ?? .now),
              let lastPlayIntentRaw else { return nil }
        return PlayIntent(rawValue: lastPlayIntentRaw)
    }
    func isNearMeal(at date: Date = .now, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return [firstMealHour, lastMealHour].contains { abs($0 - hour) <= 1 }
    }
}

@Model final class EnrichmentSession {
    var petID: UUID?
    var activityID: String
    var activityTitle: String
    var categoryRaw: String
    var petName: String
    var completedAt: Date
    var reactionRaw: String
    var note: String
    @Attribute(.externalStorage) var photoData: Data?
    var presetDurationSeconds: Int = 0
    var actualDurationSeconds: Int = 0
    var earlyStopReasonRaw: String?
    var combinedSessionID: UUID?
    var combinedActivityIDs: [String] = []

    init(activity: Activity, pet: PetProfile, reaction: Reaction, note: String = "", photoData: Data? = nil, actualDurationSeconds: Int? = nil, earlyStopReason: EarlyStopReason? = nil, combinedSessionID: UUID? = nil, combinedActivityIDs: [String] = []) {
        petID = pet.id; activityID = activity.id; activityTitle = activity.displayTitle; categoryRaw = activity.category.rawValue
        petName = pet.name; completedAt = .now; reactionRaw = reaction.rawValue; self.note = note; self.photoData = photoData
        presetDurationSeconds = activity.durationMinutes * 60
        self.actualDurationSeconds = max(0, actualDurationSeconds ?? activity.durationMinutes * 60)
        earlyStopReasonRaw = earlyStopReason?.rawValue
        self.combinedSessionID = combinedSessionID
        self.combinedActivityIDs = combinedActivityIDs
    }
    var reaction: Reaction { Reaction(rawValue: reactionRaw) ?? .fine }
    var category: ActivityCategory { ActivityCategory(rawValue: categoryRaw) ?? .social }
    var earlyStopReason: EarlyStopReason? { earlyStopReasonRaw.flatMap(EarlyStopReason.init(rawValue:)) }
    var effectiveActualSeconds: Int { actualDurationSeconds > 0 ? actualDurationSeconds : presetDurationSeconds }
    var actualMinutes: Int { effectiveActualSeconds == 0 ? 0 : max(1, Int(ceil(Double(effectiveActualSeconds) / 60))) }
    var endedEarly: Bool { actualDurationSeconds + 15 < presetDurationSeconds }
}

@Model final class FavoriteActivity {
    var petID: UUID
    var activityID: String
    var createdAt: Date
    init(petID: UUID, activityID: String) { self.petID = petID; self.activityID = activityID; createdAt = .now }
}

@Model final class ActivitySwap {
    var petID: UUID
    var activityID: String
    var swappedAt: Date
    init(petID: UUID, activityID: String) { self.petID = petID; self.activityID = activityID; swappedAt = .now }
}

@Model final class EngagementEntry {
    var petID: UUID
    var levelRaw: Int
    var note: String
    var recordedAt: Date

    init(petID: UUID, level: EngagementLevel, note: String = "", recordedAt: Date = .now) {
        self.petID = petID
        levelRaw = level.rawValue
        self.note = note
        self.recordedAt = recordedAt
    }

    var level: EngagementLevel { EngagementLevel(rawValue: levelRaw) ?? .curious }
}

@Model final class HouseholdMember {
    var id: UUID = UUID()
    var petID: UUID
    var name: String
    var createdAt: Date
    init(petID: UUID, name: String) { self.petID = petID; self.name = name; createdAt = .now }
}

@Model final class CareTask {
    var id: UUID = UUID()
    var petID: UUID
    var title: String
    var assignedMemberID: UUID?
    var isDone: Bool
    var createdAt: Date
    var kindRaw: String = CareKind.other.rawValue
    var cadenceRaw: String = CareCadence.asNeeded.rawValue
    var lastCompletedAt: Date?
    var consentGuidanceEnabled: Bool = true
    init(petID: UUID, title: String, assignedMemberID: UUID? = nil, kind: CareKind = .other, cadence: CareCadence = .asNeeded, consentGuidanceEnabled: Bool = true) {
        self.petID = petID; self.title = title; self.assignedMemberID = assignedMemberID; isDone = false; createdAt = .now
        kindRaw = kind.rawValue; cadenceRaw = cadence.rawValue; self.consentGuidanceEnabled = consentGuidanceEnabled
    }
    var kind: CareKind { CareKind(rawValue: kindRaw) ?? .other }
    var cadence: CareCadence { CareCadence(rawValue: cadenceRaw) ?? .asNeeded }
    var isDue: Bool {
        guard let nextDueDate else { return lastCompletedAt == nil }
        return nextDueDate <= .now
    }
    var nextDueDate: Date? {
        guard let lastCompletedAt else { return cadence == .asNeeded ? nil : createdAt }
        let calendar = Calendar.current
        switch cadence {
        case .twiceDaily: return calendar.date(byAdding: .hour, value: 12, to: lastCompletedAt)
        case .daily: return calendar.date(byAdding: .day, value: 1, to: lastCompletedAt)
        case .everyOtherDay: return calendar.date(byAdding: .day, value: 2, to: lastCompletedAt)
        case .twiceWeekly: return calendar.date(byAdding: .day, value: 3, to: lastCompletedAt)
        case .weekly: return calendar.date(byAdding: .day, value: 7, to: lastCompletedAt)
        case .biweekly: return calendar.date(byAdding: .day, value: 14, to: lastCompletedAt)
        case .monthly: return calendar.date(byAdding: .month, value: 1, to: lastCompletedAt)
        case .asNeeded: return nil
        }
    }
}

@Model final class CareCompletion {
    var id: UUID = UUID()
    var petID: UUID
    var taskID: UUID
    var kindRaw: String
    var completedAt: Date
    init(task: CareTask, completedAt: Date = .now) {
        petID = task.petID; taskID = task.id; kindRaw = task.kindRaw; self.completedAt = completedAt
    }
    var kind: CareKind { CareKind(rawValue: kindRaw) ?? .other }
}

@Model final class PetNote {
    var id: UUID = UUID()
    var petID: UUID
    var text: String
    var createdAt: Date

    init(petID: UUID, text: String, createdAt: Date = .now) {
        self.petID = petID
        self.text = text
        self.createdAt = createdAt
    }
}

struct RecommendationSignal {
    let activityID: String
    let category: ActivityCategory
    let reaction: Reaction
    let date: Date
    let presetDurationSeconds: Int
    let actualDurationSeconds: Int
    let earlyStopReason: EarlyStopReason?
    init(activityID: String, category: ActivityCategory, reaction: Reaction, date: Date, presetDurationSeconds: Int = 0, actualDurationSeconds: Int = 0, earlyStopReason: EarlyStopReason? = nil) {
        self.activityID = activityID; self.category = category; self.reaction = reaction; self.date = date
        self.presetDurationSeconds = presetDurationSeconds; self.actualDurationSeconds = actualDurationSeconds; self.earlyStopReason = earlyStopReason
    }
}

struct SwapSignal {
    let activityID: String
    let date: Date
}

struct AchievementTrack: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let earnedLevel: String?
    let nextLevel: String?
    let current: Int
    let target: Int
    var progress: Double { target == 0 ? 1 : min(1, Double(current) / Double(target)) }
}

enum AchievementEngine {
    static func tracks(history: [RecommendationSignal], calendar: Calendar = .current) -> [AchievementTrack] {
        let sorted = history.sorted { $0.date < $1.date }
        let totalMinutes = sorted.reduce(0) { $0 + max(0, $1.actualDurationSeconds / 60) }
        let loved = sorted.filter { $0.reaction == .loved }.count
        let categories = Set(sorted.map(\.category)).count
        let days = Array(Set(sorted.map { calendar.startOfDay(for: $0.date) })).sorted()
        let consecutive = longestConsecutiveDays(days, calendar: calendar)
        let weeklyMinutes = bestSevenDayMinutes(sorted, calendar: calendar)
        return [
            makeTrack(id: "weekly-time", title: "Quality time", symbol: "timer", value: weeklyMinutes, thresholds: [60, 180, 300, 600], names: ["One Good Hour", "Three-Hour Teammates", "Five-Hour Friends", "Week Together"]),
            makeTrack(id: "good-days", title: "Good days", symbol: "sun.max.fill", value: consecutive, thresholds: [3, 7, 14, 30], names: ["Three Good Days", "A Week of Play", "Two Joyful Weeks", "A Month of Moments"]),
            makeTrack(id: "adventures", title: "Adventures", symbol: "dog.fill", value: sorted.count, thresholds: [5, 15, 30, 75], names: ["Getting Started", "Play Partner", "Adventure Guide", "Enrichment Expert"]),
            makeTrack(id: "explorer", title: "Variety", symbol: "safari.fill", value: categories, thresholds: [2, 4, 6], names: ["Curious Pair", "Variety Seeker", "Whole-Play Explorer"]),
            makeTrack(id: "happy-hits", title: "Happy hits", symbol: "heart.fill", value: loved, thresholds: [3, 10, 25], names: ["Found a Favorite", "Joy Finder", "Happiness Expert"]),
            makeTrack(id: "lifetime-time", title: "Time together", symbol: "infinity", value: totalMinutes, thresholds: [120, 600, 1_500], names: ["Two Hours Together", "Ten-Hour Bond", "Twenty-Five-Hour Team"])
        ]
    }

    private static func makeTrack(id: String, title: String, symbol: String, value: Int, thresholds: [Int], names: [String]) -> AchievementTrack {
        let earnedIndex = thresholds.lastIndex { value >= $0 }
        let nextIndex = thresholds.firstIndex { value < $0 }
        return AchievementTrack(id: id, title: title, symbol: symbol, earnedLevel: earnedIndex.map { names[$0] }, nextLevel: nextIndex.map { names[$0] }, current: value, target: nextIndex.map { thresholds[$0] } ?? thresholds.last ?? 1)
    }

    private static func longestConsecutiveDays(_ days: [Date], calendar: Calendar) -> Int {
        guard !days.isEmpty else { return 0 }
        var best = 1, run = 1
        for index in 1..<days.count {
            if calendar.dateComponents([.day], from: days[index - 1], to: days[index]).day == 1 { run += 1 } else { run = 1 }
            best = max(best, run)
        }
        return best
    }

    private static func bestSevenDayMinutes(_ history: [RecommendationSignal], calendar: Calendar) -> Int {
        history.reduce(0) { best, signal in
            let end = calendar.date(byAdding: .day, value: 7, to: signal.date) ?? signal.date
            let minutes = history.filter { $0.date >= signal.date && $0.date < end }.reduce(0) { $0 + max(0, $1.actualDurationSeconds / 60) }
            return max(best, minutes)
        }
    }
}
