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
                    TodayDateCard(
                        selectedDateBinding: selectedDateBinding,
                        resetToToday: appModel.resetToToday
                    )
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

                HStack(spacing: 8) {
                    PrayerbookBadge(title: "Offline", tone: .neutral)
                    PrayerbookBadge(title: appModel.selectedMassFormTitle, tone: .accent)
                }
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

                HStack(spacing: 8) {
                    PrayerbookBadge(
                        title: appModel.coverageTitle,
                        tone: appModel.isOutsideCoverageWindow ? .neutral : .accent
                    )
                    PrayerbookBadge(title: appModel.selectedMassFormTitle, tone: .neutral)
                }

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

                Text(
                    """
                    Choose the form you are actually attending so the guide can surface the right landmarks,
                    response expectations, and chant cues without pretending one pattern fits every parish.
                    """
                )
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct TodayDateCard: View {
    let selectedDateBinding: Binding<Date>
    let resetToToday: () -> Void

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

                Text(
                    """
                    The app stays offline after install. It only shows bundled propers when the selected date
                    belongs to the supported 2026 Sunday-and-feast bundle.
                    """
                )
                .font(.caption)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

                Button("Reset to Today", action: resetToToday)
                    .buttonStyle(TodaySecondaryButtonStyle())
                    .accessibilityIdentifier("reset-to-today-button")
                    .accessibilityLabel("Reset the selected date to today")
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
                    The guide is meant to keep you recollected and oriented inside the rite.
                    It does not replace a full hand missal and it does not promise coverage beyond
                    the bundled year. If you lose your place, come back by posture, chant, and major
                    landmarks rather than trying to recover every line.
                    """
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
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
                    This app is a bounded companion for the 1962 Mass. It is meant to help you recognize
                    the fixed Ordinary, follow the principal bundled propers, and recover calmly when you
                    lose your place.
                    """
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

                Text(
                    """
                    Posture, spoken responses, and Sung-versus-Low customs can vary locally. The app tries
                    to orient you without overclaiming certainty where parish custom differs, and without
                    pretending to cover more than the bundle actually ships.
                    """
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

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
                    The app keeps its content bundled on-device and carries source references into the guide
                    and learning sections so you can see what is anchored in the missal tradition, what is
                    editorial adaptation, and where the bundle deliberately stops.
                    """
                )
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

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
            .font(.system(.headline, design: .serif))
            .foregroundStyle(AppTheme.ink)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.secondarySurface.opacity(configuration.isPressed ? 0.82 : 1.0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
