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
    static let sniffInk = Color(red: 74/255, green: 58/255, blue: 84/255)
    static let sniffMuted = Color(red: 112/255, green: 96/255, blue: 118/255)
    static let sniffBlue = Color(red: 75/255, green: 94/255, blue: 201/255)
    static let sniffPaper = Color(red: 255/255, green: 247/255, blue: 242/255)
    static let sniffSurface = Color(red: 247/255, green: 242/255, blue: 252/255)
    static let sniffLine = Color(red: 218/255, green: 207/255, blue: 220/255)
    static let sniffCoral = Color(red: 235/255, green: 101/255, blue: 88/255)
    static let sniffMint = Color(red: 42/255, green: 157/255, blue: 126/255)
    static let sniffPink = Color(red: 226/255, green: 104/255, blue: 158/255)
    static let sniffPurple = Color(red: 124/255, green: 91/255, blue: 202/255)
    static let sniffGold = Color(red: 186/255, green: 128/255, blue: 24/255)
    static let sniffLavender = Color(red: 232/255, green: 221/255, blue: 251/255)
    static let sniffPeach = Color(red: 255/255, green: 220/255, blue: 205/255)
    static let sniffAqua = Color(red: 28/255, green: 151/255, blue: 158/255)
    static let sniffMango = Color(red: 236/255, green: 137/255, blue: 45/255)
    static let sniffBerry = Color(red: 184/255, green: 66/255, blue: 137/255)
    static let sniffLime = Color(red: 128/255, green: 190/255, blue: 85/255)
    static let sniffSky = Color(red: 64/255, green: 155/255, blue: 225/255)
    static let sniffButter = Color(red: 1, green: 244/255, blue: 186/255)
}
