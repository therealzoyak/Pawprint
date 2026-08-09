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
    static let sniffBlue = Color(red: 104/255, green: 119/255, blue: 190/255)
    static let sniffPaper = Color(red: 253/255, green: 249/255, blue: 247/255)
    static let sniffSurface = Color(red: 249/255, green: 246/255, blue: 251/255)
    static let sniffLine = Color(red: 229/255, green: 222/255, blue: 229/255)
    static let sniffCoral = Color(red: 225/255, green: 132/255, blue: 119/255)
    static let sniffMint = Color(red: 82/255, green: 164/255, blue: 145/255)
    static let sniffPink = Color(red: 218/255, green: 137/255, blue: 166/255)
    static let sniffPurple = Color(red: 145/255, green: 126/255, blue: 192/255)
    static let sniffGold = Color(red: 210/255, green: 169/255, blue: 91/255)
    static let sniffLavender = Color(red: 239/255, green: 234/255, blue: 247/255)
    static let sniffPeach = Color(red: 249/255, green: 232/255, blue: 225/255)
    static let sniffAqua = Color(red: 64/255, green: 164/255, blue: 169/255)
    static let sniffMango = Color(red: 225/255, green: 154/255, blue: 85/255)
    static let sniffBerry = Color(red: 184/255, green: 101/255, blue: 148/255)
    static let sniffLime = Color(red: 128/255, green: 190/255, blue: 85/255)
    static let sniffSky = Color(red: 64/255, green: 155/255, blue: 225/255)
    static let sniffButter = Color(red: 1, green: 244/255, blue: 186/255)
}
