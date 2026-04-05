import SwiftUI

struct IPadRootShell: View {
    let appModel: AppModel
    let supportTipJar: SupportTipJar
    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: tab.systemImage)
                            Text(tab.title)
                            Spacer()
                            if selectedTab == tab {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.burgundy)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("sidebar-tab-\(tab.rawValue)")
                }
            }
            .navigationTitle("Latin Mass")
            .listStyle(.sidebar)
        } detail: {
            detailView
                .background(AppTheme.backgroundWash)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .guide:
            GuideWorkspaceView(appModel: appModel, selectedTab: $selectedTab)
        case .calendar:
            CalendarView(appModel: appModel, selectedTab: $selectedTab)
        case .library:
            LibraryView(appModel: appModel, selectedTab: $selectedTab)
        case .learn:
            LearnView(appModel: appModel, supportTipJar: supportTipJar)
        }
    }
}

private struct GuideWorkspaceView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            GuideWorkspaceRail(appModel: appModel, selectedTab: $selectedTab)
                .frame(minWidth: 300, idealWidth: 340, maxWidth: 360)

            Divider()

            NavigationStack {
                GuideView(
                    appModel: appModel,
                    selectedTab: $selectedTab,
                    showsInlineTools: false
                )
            }
        }
    }
}

private struct GuideWorkspaceRail: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    private var selectedMassFormBinding: Binding<MassForm> {
        Binding(
            get: { appModel.selectedMassForm },
            set: { appModel.selectMassForm($0) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(appModel.selectedCelebrationTitle)
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .foregroundStyle(AppTheme.ink)

                    Text(appModel.selectedDateLongTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.burgundy)

                    Text(appModel.selectedCelebrationSummary)
                        .font(.body)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        PrayerbookBadge(title: appModel.currentCoverageBadgeTitle, tone: .accent)
                        PrayerbookBadge(title: appModel.selectedMassFormTitle, tone: .neutral)
                    }
                }
                .prayerbookPanel()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Mass Form")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.mutedInk)

                    Picker("Mass Form", selection: selectedMassFormBinding) {
                        ForEach(MassForm.allCases) { massForm in
                            Text(massForm.title).tag(massForm)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .prayerbookPanel()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Find My Place")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)

                    ForEach(appModel.findMyPlaceAnchors) { anchor in
                        Button {
                            appModel.openGuideSection(anchor.partID)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(anchor.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                Text(anchor.summary)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppTheme.secondarySurface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .prayerbookPanel()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Major Moments")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)

                    ForEach(appModel.majorMomentAnchors) { anchor in
                        Button {
                            appModel.openGuideSection(anchor.partID)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(anchor.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                Text(anchor.summary)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedInk)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppTheme.secondarySurface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("ipad-major-moment-\(anchor.id)")
                    }
                }
                .prayerbookPanel()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Quick Tools")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)

                    Button("Browse the Calendar") {
                        selectedTab = .calendar
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.burgundy)

                    Button(appModel.bookmarkedParts.isEmpty ? "Open Library" : "Open Saved Sections") {
                        appModel.focusBookmarkedSections()
                        selectedTab = .library
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.burgundy)

                    if appModel.resumePreview != nil {
                        Button("Resume Saved Place") {
                            appModel.resumeMass()
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.burgundy)
                    }
                }
                .prayerbookPanel()
            }
            .padding(20)
        }
        .background(AppTheme.backgroundWash)
    }
}
