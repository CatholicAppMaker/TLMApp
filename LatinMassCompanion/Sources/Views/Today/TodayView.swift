import SwiftUI

struct TodayView: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    private var selectedDateBinding: Binding<Date> {
        Binding(
            get: { appModel.selectedDate },
            set: { appModel.selectDate($0) }
        )
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TodayHeader(appModel: appModel)
                    TodayCelebrationCard(appModel: appModel)
                    TodayDateCard(selectedDateBinding: selectedDateBinding)
                    TodayActions(
                        appModel: appModel,
                        selectedTab: $selectedTab
                    )

                    if let resumePreview = appModel.resumePreview {
                        ResumeMassCard(
                            preview: resumePreview,
                            resume: resumeMass
                        )
                    }

                    TodayAboutCard(
                        openLearn: {
                            appModel.openLearn(.participation("participating-at-low-mass"))
                            selectedTab = .learn
                        }
                    )

                    TodayCoverageCard(appModel: appModel)
                    TodaySourcesCard(
                        coverageWindowTitle: appModel.coverageWindowTitle,
                        coverageWindowDateText: appModel.coverageWindowDateText,
                        sources: appModel.sources
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resumeMass() {
        appModel.resumeMass()
        selectedTab = .guide
    }
}

private struct TodayHeader: View {
    let appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appModel.libraryTitle)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(AppTheme.ink)

            Text(appModel.selectedDateTitle)
                .font(.headline)
                .foregroundStyle(AppTheme.burgundy)

            Text(appModel.librarySubtitle)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
        }
    }
}

private struct TodayCelebrationCard: View {
    let appModel: AppModel

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(appModel.selectedCelebrationTitle)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                    .accessibilityIdentifier("today-celebration-title")

                Text(appModel.selectedCelebrationSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)

                Text(appModel.selectedCelebrationSummary)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedInk)

                Divider()
                    .overlay(AppTheme.divider)

                Text(appModel.coverageTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(appModel.isOutsideCoverageWindow ? AppTheme.mutedInk : AppTheme.burgundy)
                    .accessibilityIdentifier("today-coverage-title")

                Text(appModel.availabilitySummary)
                    .font(.subheadline)
                    .foregroundStyle(appModel.isOutsideCoverageWindow ? AppTheme.mutedInk : AppTheme.burgundy)
                    .accessibilityIdentifier("today-availability-summary")
            }
        }
    }
}

private struct TodayDateCard: View {
    let selectedDateBinding: Binding<Date>

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Select a Date")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                DatePicker(
                    "Mass Date",
                    selection: selectedDateBinding,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accessibilityIdentifier("today-date-picker")

                Text("The guide stays offline and only shows bundled propers when the selected date is covered.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
    }
}

private struct TodayCoverageCard: View {
    let appModel: AppModel

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(appModel.coverageWindowTitle)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                if !appModel.coverageWindowDateText.isEmpty {
                    Text(appModel.coverageWindowDateText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.burgundy)
                }

                Text(appModel.coverageSummary)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedInk)

                if !appModel.coverageWindowDescription.isEmpty {
                    Text(appModel.coverageWindowDescription)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
        }
    }
}

private struct TodayActions: View {
    let appModel: AppModel
    @Binding var selectedTab: AppTab

    var body: some View {
        TodayCard {
            VStack(spacing: 10) {
                Button("Open Guide") {
                    appModel.startGuide()
                    selectedTab = .guide
                }
                .buttonStyle(TodayPrimaryButtonStyle())
                .accessibilityIdentifier("open-guide-button")

                Button("Browse Library") {
                    selectedTab = .library
                }
                .buttonStyle(TodaySecondaryButtonStyle())

                Button("Open Learn") {
                    appModel.clearLearnFocus()
                    selectedTab = .learn
                }
                .buttonStyle(TodaySecondaryButtonStyle())
            }
        }
    }
}

private struct ResumeMassCard: View {
    let preview: ResumePreview
    let resume: () -> Void

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Resume Mass")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text(preview.partTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)
                    .accessibilityIdentifier("resume-mass-part-title")

                Text("\(preview.celebrationTitle) • \(preview.dateText)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)

                Text("Last opened \(preview.lastOpenedText).")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)

                Button("Resume Mass", action: resume)
                    .buttonStyle(TodayPrimaryButtonStyle())
                    .accessibilityIdentifier("resume-mass-button")
            }
        }
    }
}

private struct TodayAboutCard: View {
    let openLearn: () -> Void

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("About This App")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text(
                    "Use Today to pick a date, Guide to follow the Mass section by section, "
                        + "Library to search the text, and Learn for pronunciation and participation help."
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

                Text(
                    "When a selected date has no bundled propers, the app falls back to the fixed Ordinary without guessing missing texts."
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

                Button("How to Participate", action: openLearn)
                    .buttonStyle(TodaySecondaryButtonStyle())
                    .accessibilityIdentifier("open-participation-guide-button")
            }
        }
    }
}

private struct TodaySourcesCard: View {
    let coverageWindowTitle: String
    let coverageWindowDateText: String
    let sources: [SourceReference]

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Sources and Rights")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)

                Text(
                    "The app keeps its content bundled on-device and shows the source references "
                        + "that support the guide and learning material."
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

                if !coverageWindowDateText.isEmpty {
                    Text("\(coverageWindowTitle): \(coverageWindowDateText)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.burgundy)
                }

                NavigationLink("View Sources and Rights") {
                    SourcesView(
                        coverageWindowTitle: coverageWindowTitle,
                        coverageWindowDateText: coverageWindowDateText,
                        sources: sources
                    )
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)
                .accessibilityIdentifier("view-sources-button")
            }
        }
    }
}

private struct TodayCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

private struct TodayPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .font(.headline)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.burgundy.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
    }
}

private struct TodaySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .font(.headline)
            .foregroundStyle(AppTheme.ink)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.surface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
