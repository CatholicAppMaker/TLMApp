import SwiftUI

enum AppTab: String, Hashable, CaseIterable, Identifiable {
    case guide
    case calendar
    case library
    case learn

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .guide:
            "Guide"
        case .calendar:
            "Calendar"
        case .library:
            "Library"
        case .learn:
            "Learn"
        }
    }

    var systemImage: String {
        switch self {
        case .guide:
            "book.pages"
        case .calendar:
            "calendar"
        case .library:
            "text.book.closed"
        case .learn:
            "character.book.closed"
        }
    }
}

struct RootTabView: View {
    let appModel: AppModel
    let supportTipJar: SupportTipJar

    @State private var selectedTab: AppTab = .guide

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        Group {
            if isPad {
                IPadRootShell(
                    appModel: appModel,
                    supportTipJar: supportTipJar,
                    selectedTab: $selectedTab
                )
            } else {
                PhoneTabShell(
                    appModel: appModel,
                    supportTipJar: supportTipJar,
                    selectedTab: $selectedTab
                )
            }
        }
        .tint(AppTheme.burgundy)
        .preferredColorScheme(appModel.selectedAppearance.colorScheme)
        .onOpenURL(perform: handleURL)
    }

    private func handleURL(_ url: URL) {
        guard let route = AppRoute(url: url) else {
            return
        }

        switch route {
        case .guideToday:
            appModel.resetToToday()
            selectedTab = .guide
        case .guideResume:
            appModel.resumeMass()
            selectedTab = .guide
        case let .guideSection(partID):
            appModel.openGuideSection(partID)
            selectedTab = .guide
        case let .calendar(dateKey):
            if let dateKey,
               let date = AppModel.storageDateFormatter.date(from: dateKey)
            {
                appModel.selectDate(date)
            } else {
                appModel.resetToToday()
            }
            selectedTab = .calendar
        case .librarySaved:
            appModel.focusBookmarkedSections()
            selectedTab = .library
        }
    }
}

private struct PhoneTabShell: View {
    let appModel: AppModel
    let supportTipJar: SupportTipJar
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                GuideView(appModel: appModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Label(AppTab.guide.title, systemImage: AppTab.guide.systemImage)
            }
            .tag(AppTab.guide)

            NavigationStack {
                CalendarView(appModel: appModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Label(AppTab.calendar.title, systemImage: AppTab.calendar.systemImage)
            }
            .tag(AppTab.calendar)

            NavigationStack {
                LibraryView(appModel: appModel, selectedTab: $selectedTab)
            }
            .tabItem {
                Label(AppTab.library.title, systemImage: AppTab.library.systemImage)
            }
            .tag(AppTab.library)

            NavigationStack {
                LearnView(appModel: appModel, supportTipJar: supportTipJar)
            }
            .tabItem {
                Label(AppTab.learn.title, systemImage: AppTab.learn.systemImage)
            }
            .tag(AppTab.learn)
        }
        .toolbarBackground(AppTheme.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
