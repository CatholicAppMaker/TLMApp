import SwiftUI

struct LibraryView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    @State private var searchText = ""
    @State private var scope: LibraryScope = .allSections

    private var selectedMassFormBinding: Binding<MassForm> {
        Binding(
            get: { appModel.selectedMassForm },
            set: { appModel.selectMassForm($0) }
        )
    }

    private var results: LibrarySearchResults {
        appModel.search(query: searchText, scope: scope)
    }

    private var shouldPrioritizeLearningResults: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !results.learningItems.isEmpty
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            List {
                searchSection

                if results.isEmpty {
                    if scope == .bookmarks, appModel.bookmarkedParts.isEmpty {
                        EmptyView()
                            .listRowBackground(Color.clear)
                    } else {
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text("Try a prayer, response, proper, chant topic, or section name.")
                        )
                        .listRowBackground(Color.clear)
                    }
                } else {
                    if shouldPrioritizeLearningResults {
                        learningSection
                        massSections
                    } else {
                        massSections
                        learningSection
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listSectionSeparator(.hidden)
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            scope = appModel.preferredLibraryScope
        }
        .onChange(of: scope) { _, newValue in
            appModel.setPreferredLibraryScope(newValue)
        }
    }

    private func openLearningItem(_ item: LearningSearchResult) {
        appModel.openLearn(item.destination)
        selectedTab = .learn
    }

    private var searchSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                LibraryContextCard(
                    title: appModel.selectedCelebrationTitle,
                    subtitle: "\(appModel.selectedDateTitle) • \(appModel.selectedMassFormTitle)",
                    caption: appModel.isShowingOrdinaryOnly
                        ? "Ordinary-only fallback remains searchable and clearly labeled."
                        : "Bundled propers, Bookmarks, and learning notes stay separated but close at hand."
                )
                .accessibilityIdentifier("library-hero-card")

                Text(appModel.availabilitySummary)
                    .font(.caption)
                    .foregroundStyle(appModel.isShowingOrdinaryOnly ? AppTheme.mutedInk : AppTheme.burgundy)

                if scope == .bookmarks {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bookmarks")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(AppTheme.ink)

                        Text("Bookmarked sections from Guide appear here for quick return.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !appModel.bookmarkedParts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(appModel.bookmarkCountText) ready for quick return in Bookmarks.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.burgundy)

                        Text(
                            """
                            Bookmarked sections from Guide appear here when you want
                            to reopen important moments without searching during Mass.
                            """
                        )
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(scope == .bookmarks ? "Show All" : "Open Bookmarks") {
                            scope = scope == .bookmarks ? .allSections : .bookmarks
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.burgundy)
                        .accessibilityIdentifier("library-saved-sections-button")
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.toolFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
                    )
                } else if scope == .bookmarks {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("No Bookmarks Yet", systemImage: "bookmark")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(AppTheme.ink)

                        Text("Bookmark a section in Guide, then return here and open Bookmarks for quick access.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.referenceFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                } else {
                    Text("Bookmark sections from Guide, then return here to open Bookmarks quickly.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Picker("Mass Form", selection: selectedMassFormBinding) {
                    ForEach(MassForm.allCases) { massForm in
                        Text(massForm.title).tag(massForm)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("library-mass-form-toggle")

                Picker("Scope", selection: $scope) {
                    ForEach(LibraryScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("library-scope-toggle")

                TextField("Search the selected Mass and learning guides", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.secondarySurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .submitLabel(.search)
                    .accessibilityIdentifier("library-search-field")

                Text(
                    """
                    Search across the resolved Mass text, bundled propers, Bookmarks,
                    and the learning material that helps you recover by landmarks.
                    Learning matches stay separate so explanatory notes never pretend to be the rite itself.
                    """
                )
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private var massSections: some View {
        if !results.parts.isEmpty {
            Section(scope == .bookmarks ? "Bookmarks" : "Mass Sections") {
                ForEach(results.parts) { part in
                    NavigationLink {
                        LibraryPartDetailView(
                            appModel: appModel,
                            selectedTab: $selectedTab,
                            part: part
                        )
                    } label: {
                        LibraryRow(
                            part: part,
                            isBookmarked: appModel.isBookmarked(part)
                        )
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
    }

    @ViewBuilder
    private var learningSection: some View {
        if !results.learningItems.isEmpty {
            Section("Learning") {
                ForEach(results.learningItems) { item in
                    Button {
                        openLearningItem(item)
                    } label: {
                        LearningLibraryRow(item: item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("library-learning-\(item.id)")
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}

private struct LibraryContextCard: View {
    let title: String
    let subtitle: String
    let caption: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Search the Rite")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)

                Text(title)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(AppTheme.mutedInk)

                Text(caption)
                    .font(.caption)
                    .foregroundStyle(AppTheme.burgundy)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            LiturgicalMotifBadge(kind: .guide)
                .frame(width: 56, height: 56)
        }
        .prayerbookPanel(style: .tool)
    }
}

private struct LibraryRow: View {
    let part: ResolvedMassPart
    let isBookmarked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(part.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                        .accessibilityIdentifier("library-row-\(part.id)")

                    Text(part.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    PrayerbookBadge(
                        title: part.libraryCategoryTitle,
                        tone: part.isProper ? .accent : .neutral
                    )
                    PrayerbookBadge(title: part.massForm.libraryBadge, tone: .neutral)

                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(AppTheme.burgundy)
                    }
                }
            }

            Text("\(part.phase.title) • \(part.libraryCategoryTitle) • \(part.massForm.title)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)

            Text(part.tags.joined(separator: "  •  "))
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)

            if let celebrationTitle = part.celebrationTitle {
                Text(celebrationTitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
            }

            Text(part.isProper ? "Proper-backed for the selected day." : "Ordinary text available across covered and fallback dates.")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    isBookmarked
                        ? AnyShapeStyle(AppTheme.selectedRowFill)
                        : AnyShapeStyle(AppTheme.referenceFill)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isBookmarked ? AppTheme.burgundy.opacity(0.34) : AppTheme.border.opacity(0.92), lineWidth: 1)
        )
        .padding(.vertical, 6)
    }
}

private struct LearningLibraryRow: View {
    let item: LearningSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                        .accessibilityIdentifier("library-learning-title-\(item.id)")

                    Text(item.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineLimit(2)
                }

                Spacer()

                PrayerbookBadge(title: item.categoryTitle, tone: .accent)
            }

            Text("Learning material remains separate from the Mass text so explanation never pretends to be the rite itself.")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.referenceFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.border.opacity(0.92), lineWidth: 1)
        )
        .padding(.vertical, 6)
    }
}

private struct LibraryPartDetailView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab
    let part: ResolvedMassPart

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            MassPartDetailView(
                part: part,
                position: appModel.displayIndex(for: part),
                totalCount: appModel.orderedParts.count,
                orientation: appModel.guideOrientation(for: part),
                isBookmarked: appModel.isBookmarked(part),
                sourceReferences: appModel.sourceReferences(for: part),
                quickGuidance: part.quickGuidance,
                glossaryEntries: part.glossaryIDs.compactMap(appModel.glossaryEntry(withID:)),
                pronunciationGuides: part.pronunciationIDs.compactMap(appModel.pronunciationGuide(withID:)),
                chantGuides: appModel.chantGuides(for: part),
                onToggleBookmark: {
                    appModel.toggleBookmark(for: part)
                },
                onJump: nil,
                onOpenLearn: { destination in
                    appModel.openLearn(destination)
                    selectedTab = .learn
                },
                topAccessory: nil
            )
        }
        .navigationTitle(part.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
