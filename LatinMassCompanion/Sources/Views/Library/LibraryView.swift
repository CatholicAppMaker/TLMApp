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
            AppTheme.background.ignoresSafeArea()

            List {
                searchSection

                if results.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different prayer, response, proper, or section name.")
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
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text(appModel.selectedDateTitle)
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

                TextField("Search the selected Mass", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppTheme.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .accessibilityIdentifier("library-search-field")

                Text("Search across the resolved Mass text, bundled propers, and learning material. Learning matches appear in their own section.")
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
            HStack {
                Text(part.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                    .accessibilityIdentifier("library-row-\(part.id)")

                Spacer()

                Text(part.isProper ? "Proper" : "Ordinary")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(part.isProper ? AppTheme.burgundy : AppTheme.mutedInk)

                if isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(AppTheme.burgundy)
                }
            }

            Text(part.summary)
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
                .lineLimit(2)

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
            HStack {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Spacer()

                Text(item.categoryTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)
            }

            Text(item.summary)
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }
}

private struct LibraryPartDetailView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab
    let part: ResolvedMassPart

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            MassPartDetailView(
                part: part,
                position: appModel.displayIndex(for: part),
                totalCount: appModel.orderedParts.count,
                orientation: appModel.guideOrientation(for: part),
                isBookmarked: appModel.isBookmarked(part),
                sourceReferences: appModel.sourceReferences(for: part),
                glossaryEntries: part.glossaryIDs.compactMap(appModel.glossaryEntry(withID:)),
                pronunciationGuides: part.pronunciationIDs.compactMap(appModel.pronunciationGuide(withID:)),
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
