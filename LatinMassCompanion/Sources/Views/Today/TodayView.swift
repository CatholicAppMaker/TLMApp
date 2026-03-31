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

    private var selectedMassFormBinding: Binding<MassForm> {
        Binding(
            get: { appModel.selectedMassForm },
            set: { appModel.selectMassForm($0) }
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TodayHeader(appModel: appModel)
                    TodayCelebrationCard(appModel: appModel)
                    TodayMassFormCard(selectedMassFormBinding: selectedMassFormBinding)
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

                    TodayExpectationCard(appModel: appModel)
                    TodayAboutCard(
                        openFirstVisit: {
                            appModel.openLearn(.participation("first-time-at-the-1962-mass"))
                            selectedTab = .learn
                        },
                        openChangesGuide: {
                            appModel.openLearn(.participation("what-changes-by-day"))
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
        VStack(alignment: .leading, spacing: 10) {
            Text(appModel.libraryTitle)
                .font(.system(size: 31, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.ink)

            Text(appModel.librarySubtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)

            LiturgicalRule()

            HStack(alignment: .firstTextBaseline) {
                Text(appModel.selectedDateTitle)
                    .font(.headline)
                    .foregroundStyle(AppTheme.burgundy)

                Spacer()

                Text(appModel.selectedMassFormTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppTheme.burgundy.opacity(0.92))
                    )
            }
        }
    }
}

private struct TodayCelebrationCard: View {
    let appModel: AppModel

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(appModel.selectedCelebrationTitle)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                    .accessibilityIdentifier("today-celebration-title")

                Text(appModel.selectedCelebrationSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)

                Text(appModel.selectedCelebrationSummary)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedInk)

                LiturgicalRule()

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

private struct TodayMassFormCard: View {
    let selectedMassFormBinding: Binding<MassForm>

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Mass Form")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Picker("Mass Form", selection: selectedMassFormBinding) {
                    ForEach(MassForm.allCases) { massForm in
                        Text(massForm.title).tag(massForm)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("today-mass-form-picker")

                Text(selectedMassFormBinding.wrappedValue.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
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
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                DatePicker(
                    "Mass Date",
                    selection: selectedDateBinding,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accessibilityIdentifier("today-date-picker")

                Text("The app stays offline after install and only shows bundled propers when the selected date is covered.")
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
                    .font(.system(.headline, design: .serif))
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

private struct TodayExpectationCard: View {
    let appModel: AppModel

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("What to Expect Today")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(appModel.expectationSummary)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedInk)

                Text(
                    """
                    The guide is meant to keep you recollected and oriented.
                    It is not trying to replace a full hand missal or claim
                    coverage beyond the bundled year.
                    """
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
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
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(preview.partTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)
                    .accessibilityIdentifier("resume-mass-part-title")

                Text("\(preview.celebrationTitle) • \(preview.dateText)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)

                Text("\(preview.massFormTitle) • last opened \(preview.lastOpenedText).")
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
    let openFirstVisit: () -> Void
    let openChangesGuide: () -> Void

    var body: some View {
        TodayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Start Here")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(
                    """
                    This app is a bounded companion for the 1962 Mass.
                    It is designed to help you follow the fixed Ordinary,
                    recognize the principal day-specific propers,
                    and stay calm when you lose your place.
                    """
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

                Text(
                    """
                    Posture, spoken responses, and Sung-versus-Low customs can vary locally.
                    The app aims to orient you without overclaiming certainty
                    where local practice differs.
                    """
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

                Button("First Time Here?", action: openFirstVisit)
                    .buttonStyle(TodaySecondaryButtonStyle())
                    .accessibilityIdentifier("open-first-visit-guide-button")

                Button("What Changes by Day?", action: openChangesGuide)
                    .buttonStyle(TodaySecondaryButtonStyle())
                    .accessibilityIdentifier("open-what-changes-button")
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
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(
                    """
                    The app keeps its content bundled on-device and surfaces
                    the source references behind the guide, learning material,
                    and chant introductions.
                    """
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
        .prayerbookPanel()
    }
}

private struct TodayPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.burgundy.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
    }
}

private struct TodaySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .font(.system(.headline, design: .serif))
            .foregroundStyle(AppTheme.ink)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.secondarySurface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
