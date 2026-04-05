import SwiftUI

enum AppTab: Hashable {
    case guide
    case library
    case learn
}

struct RootTabView: View {
    let appModel: AppModel
    let supportTipJar: SupportTipJar

    @State private var selectedTab: AppTab = .guide

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                GuideView(appModel: appModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Guide", systemImage: "book.pages")
            }
            .tag(AppTab.guide)

            NavigationStack {
                LibraryView(appModel: appModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Library", systemImage: "text.book.closed")
            }
            .tag(AppTab.library)

            NavigationStack {
                LearnView(appModel: appModel, supportTipJar: supportTipJar)
            }
            .tabItem {
                Label("Learn", systemImage: "character.book.closed")
            }
            .tag(AppTab.learn)
        }
        .tint(AppTheme.burgundy)
        .toolbarBackground(AppTheme.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(appModel.selectedAppearance.colorScheme)
    }
}
