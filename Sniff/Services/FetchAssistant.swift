import Foundation

struct FetchReply: Equatable {
    let text: String
    let activityID: String?
}

struct FetchAssistant {
    func reply(to rawQuestion: String, pet: PetProfile, candidates: [Activity]) -> FetchReply {
        let question = normalized(rawQuestion)
        let words = Set(question.split(separator: " ").map(String.init))

        if isNameRequest(question, words: words) {
            return FetchReply(text: nameReply(question: question, pet: pet), activityID: nil)
        }
        if isProfileRequest(question) {
            return FetchReply(text: profileReply(pet: pet), activityID: nil)
        }
        if isGreeting(question, words: words) {
            return FetchReply(text: "Hi! I’m Fetch. Ask me for a play idea, a calmer option, something using what’s nearby, or even fresh name ideas for \(pet.name).", activityID: nil)
        }
        return activityReply(question: question, words: words, pet: pet, candidates: candidates)
    }

    private func isNameRequest(_ question: String, words: Set<String>) -> Bool {
        let phrases = ["new name", "another name", "different name", "name idea", "name ideas", "rename", "what should i call", "what can i call", "nickname", "nick name"]
        return phrases.contains(where: question.contains)
            || (words.contains("name") && !words.isDisjoint(with: ["give", "suggest", "choose", "change", "better", "cute", "funny", "unique"]))
    }

    private func isProfileRequest(_ question: String) -> Bool {
        ["what do you know", "tell me about", "their profile", "pet profile", "what is their", "what are their"].contains(where: question.contains)
    }

    private func isGreeting(_ question: String, words: Set<String>) -> Bool {
        question.count < 40 && !words.isDisjoint(with: ["hi", "hello", "hey", "howdy", "yo", "sup"])
    }

    private func nameReply(question: String, pet: PetProfile) -> String {
        let themed: [String]
        if containsAny(question, ["funny", "silly", "weird", "goofy", "ridiculous"]) {
            themed = pet.species == .cat ? ["Chairman Meow", "Purrito", "Beans", "Crouton", "Miso", "Tofu", "Pickles", "Noodle", "Waffles", "Socks"] : ["Bark Twain", "Tater Tot", "Beans", "Pickles", "Waffles", "Noodle", "Mochi", "Toast", "Biscuit", "Sprout"]
        } else if containsAny(question, ["strong", "tough", "bold", "powerful", "hero", "cool"]) {
            themed = ["Atlas", "Nova", "Ranger", "Juno", "Onyx", "Scout", "Rogue", "Storm", "Ziggy", "Indigo"]
        } else if containsAny(question, ["cute", "sweet", "soft", "adorable", "tiny"]) {
            themed = ["Mochi", "Pip", "Biscuit", "Clover", "Peaches", "Minnie", "Button", "Poppy", "Teddy", "Dottie"]
        } else if containsAny(question, ["nature", "plant", "outdoor", "earth", "flower"]) {
            themed = ["Clover", "Juniper", "Maple", "River", "Willow", "Fern", "Sunny", "Aspen", "Pebble", "Sage"]
        } else if containsAny(question, ["unique", "unusual", "rare", "original", "different"]) {
            themed = ["Quill", "Vesper", "Kumo", "Fig", "Orbit", "Fable", "Pixel", "Echo", "Zuzu", "Marlow"]
        } else {
            themed = pet.species == .cat
                ? ["Miso", "Luna", "Jasper", "Cleo", "Mochi", "Theo", "Olive", "Cosmo", "Poppy", "Milo", "Nori", "Winnie"]
                : ["Milo", "Ruby", "Scout", "Winnie", "Finn", "Clover", "Teddy", "Poppy", "Archie", "Maple", "Otis", "Pepper"]
        }

        let current = normalized(pet.name)
        let choices = rotated(themed.filter { normalized($0) != current }, seed: question).prefix(5)
        return "If you want a fresh name for \(pet.name), try \(joined(Array(choices))). Want names that feel cuter, funnier, stronger, nature-inspired, or more unusual?"
    }

    private func profileReply(pet: PetProfile) -> String {
        let materials = pet.materials.map(\.label).sorted()
        let limitations = pet.limitations.map(\.label).sorted()
        let materialText = materials.isEmpty ? "no play materials listed yet" : "\(joined(Array(materials.prefix(4)))) available"
        let limitationText = limitations.isEmpty ? "no recorded limitations" : "the recorded needs: \(joined(limitations))"
        return "I know \(pet.name) is a \(pet.ageBand.rawValue) \(pet.species.rawValue) with \(pet.energy.rawValue) energy. Their profile has \(materialText) and \(limitationText). I use those details to keep suggestions relevant."
    }

    private func activityReply(question: String, words: Set<String>, pet: PetProfile, candidates: [Activity]) -> FetchReply {
        guard !candidates.isEmpty else {
            return FetchReply(text: "I don’t have a safe match for \(pet.name)’s current setup yet. Add a few materials to their profile and I’ll try again.", activityID: nil)
        }

        let categoryTerms: [ActivityCategory: Set<String>] = [
            .calming: ["calm", "quiet", "settle", "relax", "anxious", "nervous", "gentle", "sleepy", "bedtime", "chill", "soothe", "overwhelmed"],
            .physical: ["active", "run", "move", "zoom", "zoomies", "energy", "exercise", "chase", "jump", "tired", "workout", "outside"],
            .cognitive: ["brain", "smart", "think", "puzzle", "challenge", "hard", "tricky", "learn", "bored", "focus", "training"],
            .foraging: ["sniff", "smell", "search", "find", "hunt", "food", "treat", "kibble", "hungry", "nose", "forage"],
            .social: ["bond", "together", "cuddle", "attention", "connect", "trust", "affection", "company", "lonely", "interactive"],
            .sensory: ["explore", "texture", "sound", "curious", "new", "different", "indoor", "rain", "rainy", "discover", "sensory"]
        ]
        let requestedMinutes = parsedMinutes(from: question, words: words)
        let wantsQuick = containsAny(question, ["quick", "fast", "brief", "short", "few minutes", "not much time", "hurry"])
        let wantsEasy = containsAny(question, ["easy", "simple", "effortless", "low effort", "beginner", "simpler"])
        let wantsHard = containsAny(question, ["hard", "harder", "challenge", "challenging", "advanced", "tricky"])
        let wantsDifferent = containsAny(question, ["different", "another", "something else", "new one", "change it", "fresh"])

        var ranked: [(activity: Activity, score: Double)] = []
        for (index, activity) in candidates.enumerated() {
            let score = activityScore(
                activity,
                index: index,
                words: words,
                categoryTerms: categoryTerms,
                requestedMinutes: requestedMinutes,
                wantsQuick: wantsQuick,
                wantsEasy: wantsEasy,
                wantsHard: wantsHard,
                wantsDifferent: wantsDifferent
            )
            ranked.append((activity, score))
        }
        ranked.sort {
            if $0.score == $1.score { return $0.activity.durationMinutes < $1.activity.durationMinutes }
            return $0.score > $1.score
        }

        let match = ranked[0].activity
        let materials = match.materials.map { material in material.label }
        let materialText = materials.isEmpty ? "nothing special" : joined(materials)
        return FetchReply(
            text: "Try \(match.displayTitle) with \(pet.name). It takes about \(match.durationMinutes) minutes and uses \(materialText). \(match.description)",
            activityID: match.id
        )
    }

    private func normalized(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func containsAny(_ text: String, _ terms: [String]) -> Bool { terms.contains(where: text.contains) }

    private func parsedMinutes(from question: String, words: Set<String>) -> Int? {
        if let digits = question.split(whereSeparator: { !$0.isNumber }).compactMap({ Int($0) }).first { return digits }
        let writtenNumbers = [
            "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
            "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
            "fifteen": 15, "twenty": 20, "thirty": 30
        ]
        for (word, value) in writtenNumbers where words.contains(word) { return value }
        return nil
    }

    private func matchingWordCount(_ terms: Set<String>, in words: Set<String>) -> Int {
        var count = 0
        for term in terms where words.contains(term) { count += 1 }
        return count
    }

    private func activityScore(
        _ activity: Activity,
        index: Int,
        words: Set<String>,
        categoryTerms: [ActivityCategory: Set<String>],
        requestedMinutes: Int?,
        wantsQuick: Bool,
        wantsEasy: Bool,
        wantsHard: Bool,
        wantsDifferent: Bool
    ) -> Double {
        var score = Double(max(0, 18 - index)) * 0.18
        let relevantTerms = categoryTerms[activity.category] ?? Set<String>()
        score += Double(matchingWordCount(relevantTerms, in: words)) * 5.0

        let materialText = activity.materials.map { $0.label }.joined(separator: " ")
        let searchable = normalized(activity.displayTitle + " " + activity.description + " " + materialText)
        var overlappingWordCount = 0
        for word in words where word.count > 3 && searchable.contains(word) { overlappingWordCount += 1 }
        score += Double(overlappingWordCount) * 1.4

        if let requestedMinutes {
            score -= Double(abs(activity.durationMinutes - requestedMinutes)) * 0.7
        } else if wantsQuick {
            score -= Double(activity.durationMinutes) * 0.45
        }
        if wantsEasy { score -= Double(activity.tier) * 2.2 }
        if wantsHard { score += Double(activity.tier) * 2.2 }
        if wantsDifferent && index == 0 { score -= 4.0 }
        return score
    }

    private func rotated(_ values: [String], seed: String) -> [String] {
        guard !values.isEmpty else { return values }
        let offset = seed.unicodeScalars.reduce(0) { ($0 + Int($1.value)) % values.count }
        return Array(values[offset...] + values[..<offset])
    }

    private func joined(_ values: [String]) -> String {
        switch values.count {
        case 0: "nothing extra"
        case 1: values[0]
        case 2: "\(values[0]) or \(values[1])"
        default: "\(values.dropLast().joined(separator: ", ")), or \(values.last!)"
        }
    }
}
