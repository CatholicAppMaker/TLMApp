import SwiftUI

struct LearnView: View {
    let appModel: AppModel
    let supportTipJar: SupportTipJar

    private var selectedAppearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { appModel.selectedAppearance },
            set: { appModel.selectAppearance($0) }
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.backgroundWash)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LearnIntroCard(
                        sources: appModel.sourceReferences(for: ["ordinary", "translation", "chant"])
                    )
                    .accessibilityIdentifier("learn-intro-card")
                    LiturgicalHeroPanel(
                        eyebrow: "Prepare, Then Pray",
                        title: "Study the Mass Without Losing the Atmosphere of Worship",
                        subtitle: "These notes are here to steady your eye, your ear, and your expectations before you need them live.",
                        kind: .learn,
                        caption: "Keep the learning supportive, not louder than the rite itself."
                    )
                    .accessibilityIdentifier("learn-hero-card")
                    AppearanceLearnSection(selectedAppearanceBinding: selectedAppearanceBinding)
                    focusedSection
                    guideSection(
                        title: "Start Here",
                        subtitle: "Practical orientation for newcomers and returning visitors.",
                        guides: appModel.orientationGuides
                    )
                    guideSection(
                        title: "What Changes",
                        subtitle: "How the Ordinary, Propers, and Mass form selection affect what you see.",
                        guides: appModel.changeGuides
                    )
                    guideSection(
                        title: "Participate Calmly",
                        subtitle: "Follow the rite without turning prayer into a race.",
                        guides: appModel.participationHelpGuides
                    )
                    chantSection
                    VoicesOfTraditionSection()
                    pronunciationSection
                    glossarySection
                    SupportLearnSection(supportTipJar: supportTipJar)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 132)
            }
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await supportTipJar.loadProductsIfNeeded()
        }
    }

    @ViewBuilder
    private var focusedSection: some View {
        if let destination = appModel.focusedLearningDestination {
            LearnSectionCard(
                title: "From the Guide",
                subtitle: "This note was opened from the guide or library so you can stay oriented without hunting for it again.",
                style: .tool
            ) {
                focusedRow(for: destination)

                Button("Clear Highlight") {
                    appModel.clearLearnFocus()
                }
                .buttonStyle(LearnOutlineButtonStyle())
                .accessibilityIdentifier("learn-clear-highlight-button")
            }
            .accessibilityIdentifier("learn-focused-section")
        }
    }

    @ViewBuilder
    private func guideSection(
        title: String,
        subtitle: String,
        guides: [ParticipationGuide]
    ) -> some View {
        if !guides.isEmpty {
            LearnSectionCard(title: title, subtitle: subtitle) {
                ForEach(guides) { guide in
                    ParticipationGuideRow(
                        guide: guide,
                        sources: appModel.sourceReferences(for: guide.sourceIDs)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var chantSection: some View {
        if !appModel.chantGuides.isEmpty {
            LearnSectionCard(
                title: "Gregorian Chant",
                subtitle: "A small, text-only primer for understanding what chant is and how it helps you follow a Sung Mass."
            ) {
                ForEach(appModel.chantGuides) { guide in
                    ChantGuideRow(
                        guide: guide,
                        sources: appModel.sourceReferences(for: guide.sourceIDs)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var pronunciationSection: some View {
        if !appModel.pronunciationGuides.isEmpty {
            LearnSectionCard(
                title: "Pronunciation",
                subtitle: "Short helps for common responses and major prayer landmarks."
            ) {
                ForEach(appModel.pronunciationGuides) { guide in
                    PronunciationGuideRow(
                        guide: guide,
                        sources: appModel.sourceReferences(for: guide.sourceIDs)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var glossarySection: some View {
        if !appModel.glossaryEntries.isEmpty {
            LearnSectionCard(
                title: "Glossary",
                subtitle: "Key terms that make the guide easier to understand at a glance."
            ) {
                ForEach(appModel.glossaryEntries) { entry in
                    GlossaryEntryRow(
                        entry: entry,
                        sources: appModel.sourceReferences(for: entry.sourceIDs)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func focusedRow(for destination: LearnDestination) -> some View {
        switch destination {
        case let .glossary(id):
            if let entry = appModel.glossaryEntry(withID: id) {
                GlossaryEntryRow(
                    entry: entry,
                    sources: appModel.sourceReferences(for: entry.sourceIDs)
                )
            }
        case let .pronunciation(id):
            if let guide = appModel.pronunciationGuide(withID: id) {
                PronunciationGuideRow(
                    guide: guide,
                    sources: appModel.sourceReferences(for: guide.sourceIDs)
                )
            }
        case let .participation(id):
            if let guide = appModel.participationGuide(withID: id) {
                ParticipationGuideRow(
                    guide: guide,
                    sources: appModel.sourceReferences(for: guide.sourceIDs)
                )
            }
        case let .chant(id):
            if let guide = appModel.chantGuide(withID: id) {
                ChantGuideRow(
                    guide: guide,
                    sources: appModel.sourceReferences(for: guide.sourceIDs)
                )
            }
        }
    }
}

private struct LearnIntroCard: View {
    let sources: [SourceReference]

    var body: some View {
        LearnSectionCard(
            title: "Learn the Rite, Keep the Prayer",
            subtitle: "Use this area to prepare for the guide, then let the liturgy remain primary in church.",
            style: .hero
        ) {
            VStack(alignment: .leading, spacing: 10) {
                LearnIntroPoint(
                    title: "Know what changes",
                    message: "See what belongs to the Ordinary, what changes by day, and where local custom may differ."
                )

                LearnIntroPoint(
                    title: "Recover by landmarks",
                    message: "Follow Low or Sung Mass without expecting the phone to replace a hand missal or catch every line."
                )

                LearnIntroPoint(
                    title: "Let prayer stay primary",
                    message: "Practical confidence is enough. If you can rejoin the broad movement of the rite calmly, the app is doing its work."
                )
            }

            SourceAttributionLine(references: sources)
        }
    }
}

private struct LearnIntroPoint: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)

            Text(message)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct LearnSectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    var style: PrayerbookPanelStyle = .standard
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(AppTheme.ink)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
            }

            LiturgicalRule()
            content
        }
        .prayerbookPanel(style: style)
    }
}

private struct GlossaryEntryRow: View {
    let entry: GlossaryEntry
    let sources: [SourceReference]

    var body: some View {
        LearnRowContainer {
            Text(entry.term)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-glossary-\(entry.id)")

            Text(entry.definition)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

            if !entry.relatedTerms.isEmpty {
                Text("Related: \(entry.relatedTerms.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(AppTheme.burgundy)
            }

            SourceAttributionLine(references: sources)
        }
    }
}

private struct PronunciationGuideRow: View {
    let guide: PronunciationGuide
    let sources: [SourceReference]

    var body: some View {
        LearnRowContainer {
            Text(guide.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-pronunciation-\(guide.id)")

            Text(guide.latin)
                .font(.system(.body, design: .serif))
                .foregroundStyle(AppTheme.ink)

            Text(guide.phonetic)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)

            Text(guide.note)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

            SourceAttributionLine(references: sources)
        }
    }
}

private struct ParticipationGuideRow: View {
    let guide: ParticipationGuide
    let sources: [SourceReference]

    var body: some View {
        LearnRowContainer {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(guide.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                        .accessibilityIdentifier("learn-participation-\(guide.id)")

                    Text(guide.body)
                        .font(.body)
                        .foregroundStyle(AppTheme.mutedInk)
                }

                Spacer(minLength: 12)

                PrayerbookBadge(title: guide.kind.title, tone: .neutral)
                    .accessibilityHidden(true)
            }

            SourceAttributionLine(references: sources)
        }
    }
}

private struct ChantGuideRow: View {
    let guide: ChantGuide
    let sources: [SourceReference]

    var body: some View {
        LearnRowContainer {
            Text(guide.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("learn-chant-\(guide.id)")

            Text(guide.summary)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.burgundy)

            Text(guide.body)
                .font(.body)
                .foregroundStyle(AppTheme.mutedInk)

            SourceAttributionLine(references: sources)
        }
    }
}

struct LearnRowContainer<Content: View>: View {
    var style: PrayerbookPanelStyle = .inset
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(backgroundFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        )
    }

    private var backgroundFill: AnyShapeStyle {
        switch style {
        case .tool:
            AnyShapeStyle(AppTheme.toolFill)
        case .hero:
            AnyShapeStyle(AppTheme.heroFill)
        case .inset:
            AnyShapeStyle(AppTheme.referenceFill)
        case .standard:
            AnyShapeStyle(AppTheme.cardFill)
        }
    }

    private var strokeColor: Color {
        switch style {
        case .tool:
            AppTheme.gold.opacity(0.28)
        case .hero:
            AppTheme.burgundy.opacity(0.26)
        case .standard, .inset:
            AppTheme.border.opacity(0.9)
        }
    }
}

struct LearnOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .font(.system(.headline, design: .serif))
            .foregroundStyle(AppTheme.ink)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        configuration.isPressed
                            ? AnyShapeStyle(AppTheme.secondarySurface.opacity(0.82))
                            : AnyShapeStyle(AppTheme.referenceFill)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}
