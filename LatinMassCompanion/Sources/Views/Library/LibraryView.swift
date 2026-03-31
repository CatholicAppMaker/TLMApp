import SwiftUI

struct LibraryView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    @State private var searchText = ""
    @State private var scope: LibraryScope = .allSections

    private var results: LibrarySearchResults {
        appModel.search(query: searchText, scope: scope)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            List {
                searchSection

                if results.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try a prayer, response, proper, chant topic, or section name.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    Section("Mass Sections") {
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
                            .listRowBackground(AppTheme.surface)
                        }
                    }

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
                                .listRowBackground(AppTheme.surface)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listSectionSeparator(.hidden)
        }
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openLearningItem(_ item: LearningSearchResult) {
        appModel.openLearn(item.destination)
        selectedTab = .learn
    }

    private var searchSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                Text(appModel.selectedCelebrationTitle)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text("\(appModel.selectedDateTitle) • \(appModel.selectedMassFormTitle)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)

                Text(appModel.availabilitySummary)
                    .font(.caption)
                    .foregroundStyle(appModel.isShowingOrdinaryOnly ? AppTheme.mutedInk : AppTheme.burgundy)

                Picker("Scope", selection: $scope) {
                    ForEach(LibraryScope.allCases) { scope in
                        Text(scope.title).tag(scope)
                    }
                }
                .pickerStyle(.segmented)

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
                    .accessibilityIdentifier("library-search-field")

                Text(
                    """
                    Search across the resolved Mass text, bundled propers, glossary terms,
                    participation guides, pronunciation help, and Gregorian chant notes.
                    Learning matches appear separately.
                    """
                )
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
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
                    LibraryBadge(title: part.libraryCategoryTitle, highlighted: part.isProper)
                    LibraryBadge(title: part.massForm.libraryBadge, highlighted: false)

                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(AppTheme.burgundy)
                    }
                }
            }

            Text(part.tags.joined(separator: "  •  "))
                .font(.caption)
                .foregroundStyle(AppTheme.burgundy)

            if let celebrationTitle = part.celebrationTitle {
                Text(celebrationTitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
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

                    Text(item.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .lineLimit(2)
                }

                Spacer()

                LibraryBadge(title: item.categoryTitle, highlighted: true)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct LibraryBadge: View {
    let title: String
    let highlighted: Bool

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(highlighted ? AppTheme.gold : AppTheme.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(highlighted ? AppTheme.burgundy : AppTheme.secondarySurface)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppTheme.border, lineWidth: highlighted ? 0 : 1)
            )
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
                }
            )
        }
        .navigationTitle(part.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
