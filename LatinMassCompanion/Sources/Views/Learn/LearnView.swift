import SwiftUI

struct LearnView: View {
    let appModel: AppModel
    let supportTipJar: SupportTipJar

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
                    supportSection
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
                    pronunciationSection
                    glossarySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await supportTipJar.loadProductsIfNeeded()
        }
    }

    private var supportSection: some View {
        LearnSectionCard(
            title: "Support the App",
            subtitle: "If this companion has been useful, you can leave a simple in-app tip to support its continued development."
        ) {
            Text(
                """
                Tips are entirely optional. They do not unlock content, and the app remains fully usable without them.
                Pricing appears only when the App Store returns the live product information.
                """
            )
            .font(.body)
            .foregroundStyle(AppTheme.mutedInk)
            .fixedSize(horizontal: false, vertical: true)

            if supportTipJar.isLoadingProducts, !supportTipJar.hasLoadedProducts {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading support options…")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("support-tip-loading")
            } else if supportTipJar.hasLoadedProducts {
                ForEach(supportTipJar.options) { option in
                    Button {
                        Task {
                            await supportTipJar.purchase(option)
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(AppTheme.ink)

                                Text(option.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.mutedInk)
                            }

                            Spacer(minLength: 12)

                            if supportTipJar.isPurchasing(option) {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text(supportTipJar.displayPrice(for: option))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.burgundy)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(LearnOutlineButtonStyle())
                    .disabled(supportTipJar.purchaseInFlightID != nil || !supportTipJar.canPurchase(option))
                    .accessibilityIdentifier("support-tip-\(option.id)")
                    .accessibilityLabel("\(option.title), \(supportTipJar.displayPrice(for: option))")
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Support options will appear here once live App Store pricing is available.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)

                    Button("Try Loading Support Options Again") {
                        Task {
                            await supportTipJar.reloadProducts()
                        }
                    }
                    .buttonStyle(LearnOutlineButtonStyle())
                    .accessibilityIdentifier("support-tip-retry")
                }
            }

            if let statusMessage = supportTipJar.statusMessage {
                Text(statusMessage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)
                    .accessibilityIdentifier("support-tip-status")
            }

            if let errorMessage = supportTipJar.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.burgundy)
                    .accessibilityIdentifier("support-tip-error")
            }
        }
    }

    @ViewBuilder
    private var focusedSection: some View {
        if let destination = appModel.focusedLearningDestination {
            LearnSectionCard(
                title: "From the Guide",
                subtitle: "This note was opened from the guide or library so you can stay oriented without hunting for it again."
            ) {
                focusedRow(for: destination)

                Button("Clear Highlight") {
                    appModel.clearLearnFocus()
                }
                .buttonStyle(LearnOutlineButtonStyle())
            }
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
            subtitle: "Use this area before or after Mass to build confidence without overloading the live guide."
        ) {
            Text(
                """
                The app is a bounded companion for the 1962 Mass. It helps you understand what changes by day,
                what may vary locally, and how to follow Low or Sung Mass without expecting the phone to replace
                a hand missal or to catch every line for you.
                """
            )
            .font(.body)
            .foregroundStyle(AppTheme.mutedInk)
            .fixedSize(horizontal: false, vertical: true)

            Text(
                """
                Practical confidence is the goal here. If you can recognize the broad movement of the rite,
                recover by landmarks when you lose your place, and let the liturgy remain primary, you are
                already using the app well.
                """
            )
            .font(.subheadline)
            .foregroundStyle(AppTheme.mutedInk)
            .fixedSize(horizontal: false, vertical: true)

            SourceAttributionLine(references: sources)
        }
    }
}

private struct LearnSectionCard<Content: View>: View {
    let title: String
    let subtitle: String
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
        .prayerbookPanel()
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

private struct LearnRowContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.secondarySurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.border.opacity(0.9), lineWidth: 1)
        )
    }
}

private struct LearnOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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
