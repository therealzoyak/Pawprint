import SwiftUI
import SwiftData

@main
struct PawprintApp: App {
    private let container: ModelContainer
    private let recoveredFromStoreIssue: Bool

    init() {
        let schema = Schema([LocalAccount.self, PetProfile.self, EnrichmentSession.self, FavoriteActivity.self, ActivitySwap.self, EngagementEntry.self, HouseholdMember.self, CareTask.self, CareCompletion.self, PetNote.self])
        do {
            container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)])
            recoveredFromStoreIssue = false
        } catch {
            container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
            recoveredFromStoreIssue = true
        }
    }

    var body: some Scene {
        WindowGroup { RootView(showPersistenceWarning: recoveredFromStoreIssue) }
            .modelContainer(container)
    }
}

extension Color {
    static let sniffInk = Color(red: 22/255, green: 48/255, blue: 54/255)
    static let sniffMuted = Color(red: 91/255, green: 116/255, blue: 121/255)
    static let sniffBlue = Color(red: 20/255, green: 137/255, blue: 158/255)
    static let sniffPaper = Color(red: 248/255, green: 253/255, blue: 253/255)
    static let sniffSurface = Color(red: 238/255, green: 249/255, blue: 249/255)
    static let sniffLine = Color(red: 207/255, green: 228/255, blue: 229/255)
    static let sniffCoral = Color(red: 235/255, green: 101/255, blue: 88/255)
    static let sniffMint = Color(red: 42/255, green: 157/255, blue: 126/255)
    static let sniffPink = Color(red: 226/255, green: 104/255, blue: 158/255)
    static let sniffPurple = Color(red: 38/255, green: 125/255, blue: 151/255)
    static let sniffGold = Color(red: 186/255, green: 128/255, blue: 24/255)
    static let sniffLavender = Color(red: 222/255, green: 245/255, blue: 246/255)
    static let sniffPeach = Color(red: 255/255, green: 231/255, blue: 218/255)
    static let sniffAqua = Color(red: 0/255, green: 161/255, blue: 170/255)
    static let sniffMango = Color(red: 236/255, green: 137/255, blue: 45/255)
    static let sniffBerry = Color(red: 184/255, green: 66/255, blue: 137/255)
    static let sniffLime = Color(red: 128/255, green: 190/255, blue: 85/255)
    static let sniffSky = Color(red: 64/255, green: 155/255, blue: 225/255)
    static let sniffButter = Color(red: 1, green: 244/255, blue: 186/255)
}
