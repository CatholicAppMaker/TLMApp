import SwiftUI

struct CalendarView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var searchText = ""

    private var sections: [CelebrationMonthSection] {
        appModel.celebrationSections(matching: searchText)
    }

    private var selectedListing: CelebrationListing? {
        appModel.selectedCelebrationListing
    }

    private var isPadLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    var body: some View {
        Group {
            if isPadLayout {
                HStack(spacing: 0) {
                    calendarList
                        .frame(minWidth: 360, idealWidth: 400, maxWidth: 430)

                    Divider()

                    ScrollView {
                        previewContent
                            .padding(24)
                    }
                    .background(AppTheme.backgroundWash)
                }
                .background(AppTheme.backgroundWash)
            } else {
                ZStack {
                    Rectangle()
                        .fill(AppTheme.backgroundWash)
                        .ignoresSafeArea()

                    List {
                        searchHeader

                        Section {
                            previewContent
                                .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)

                        calendarSectionContent
                    }
                    .scrollContentBackground(.hidden)
                    .listSectionSeparator(.hidden)
                }
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var calendarList: some View {
        List {
            searchHeader
            calendarSectionContent
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.backgroundWash)
        .listSectionSeparator(.hidden)
    }

    private var searchHeader: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                LiturgicalHeroPanel(
                    eyebrow: "Calendar and Celebrations",
                    title: "Browse the Bundled Year by Feast, Sunday, and Season",
                    subtitle: "Move directly from a covered celebration into the guide or library without guessing where to begin.",
                    kind: .calendar,
                    caption: appModel.bundledCoverageSummary
                )
                .accessibilityIdentifier("calendar-hero-card")

                TextField("Search Sundays, feasts, or dates", text: $searchText)
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
                    .accessibilityIdentifier("calendar-search-field")
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var calendarSectionContent: some View {
        ForEach(sections) { section in
            Section(section.title) {
                ForEach(section.listings) { listing in
                    Button {
                        appModel.selectDate(listing.date)
                    } label: {
                        CelebrationListingRow(
                            listing: listing,
                            isSelected: listing.dateKey == appModel.selectedDateKey
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("calendar-row-\(listing.dateKey)")
                    .listRowBackground(AppTheme.surface)
                }
            }
        }
    }

    private var previewContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let selectedListing {
                CelebrationPreviewCard(
                    listing: selectedListing,
                    availabilitySummary: appModel.availabilitySummary,
                    selectedMassFormTitle: appModel.selectedMassFormTitle,
                    onOpenGuide: {
                        selectedTab = .guide
                    },
                    onOpenLibrary: {
                        selectedTab = .library
                    }
                )
            } else {
                CelebrationBundleCard(summary: appModel.bundledCoverageSummary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CelebrationBundleCard: View {
    let summary: String

    var body: some View {
        LiturgicalHeroPanel(
            eyebrow: "Covered Celebrations",
            title: "Browse the Liturgical Year",
            subtitle:
                "Use this calendar to move directly into covered Sundays and feasts, then carry that selection into Guide and Library.",
            kind: .calendar,
            caption: summary
        )
        .accessibilityIdentifier("calendar-bundle-card")
    }
}

private struct CelebrationPreviewCard: View {
    let listing: CelebrationListing
    let availabilitySummary: String
    let selectedMassFormTitle: String
    let onOpenGuide: () -> Void
    let onOpenLibrary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(AppTheme.ink)

                Text(listing.longDateText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)

                Text(listing.subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedInk)
            }

            HStack(spacing: 8) {
                PrayerbookBadge(title: listing.coverageBadgeTitle, tone: .accent)
                PrayerbookBadge(title: listing.rank, tone: .neutral)
                PrayerbookBadge(title: selectedMassFormTitle, tone: .neutral)
            }

            Text(listing.summary)
                .font(.body)
                .foregroundStyle(AppTheme.ink)

            Text(availabilitySummary)
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button("Open in Guide", action: onOpenGuide)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.burgundy)
                    .accessibilityIdentifier("calendar-open-guide-button")

                Button("Search in Library", action: onOpenLibrary)
                    .buttonStyle(.bordered)
                    .tint(AppTheme.burgundy)
                    .accessibilityIdentifier("calendar-open-library-button")
            }
        }
        .prayerbookPanel()
    }
}

private struct CelebrationListingRow: View {
    let listing: CelebrationListing
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(listing.shortDateText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)

                Text(listing.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(listing.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 6) {
                PrayerbookBadge(title: listing.coverageBadgeTitle, tone: .accent)
                PrayerbookBadge(title: listing.rank, tone: .neutral)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.burgundy)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
