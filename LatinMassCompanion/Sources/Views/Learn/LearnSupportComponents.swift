import SwiftUI

struct TraditionQuote: Identifiable {
    let id: String
    let text: String
    let attribution: String
}

private let traditionQuotes: [TraditionQuote] = [
    TraditionQuote(
        id: "faber-mass",
        text: "The Mass is the most beautiful thing this side of heaven.",
        attribution: "Fr. Frederick Faber"
    ),
    TraditionQuote(
        id: "benedict-sacred",
        text: "What earlier generations held as sacred remains sacred and great for us too.",
        attribution: "Benedict XVI"
    )
]

struct AppearanceLearnSection: View {
    let selectedAppearanceBinding: Binding<AppAppearance>

    var body: some View {
        LearnSectionCard(
            title: "Appearance",
            subtitle: "Choose the reading mode that stays clearest for your eyes and your setting.",
            style: .tool
        ) {
            Picker("Appearance", selection: selectedAppearanceBinding) {
                ForEach(AppAppearance.allCases) { appearance in
                    Text(appearance.title).tag(appearance)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("appearance-toggle")

            Text(
                """
                System follows your device. Light and Dark let you lock the guide into the mode \
                that stays most readable in church, at home, or at night.
                """
            )
            .font(.subheadline)
            .foregroundStyle(AppTheme.mutedInk)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private enum LearnQuickPathLayout {
    static let buttonSpacing: CGFloat = 10
}

struct LearnQuickPathCard: View {
    let onSelect: (LearnSectionAnchor) -> Void

    var body: some View {
        LearnSectionCard(
            title: "Use Learn For",
            subtitle: "Jump straight to the help you need instead of reading the whole tab in order.",
            style: .tool
        ) {
            VStack(spacing: LearnQuickPathLayout.buttonSpacing) {
                HStack(spacing: LearnQuickPathLayout.buttonSpacing) {
                    LearnQuickPathButton(
                        title: "Appearance",
                        systemImage: "circle.lefthalf.filled",
                        action: { onSelect(.appearance) }
                    )
                    LearnQuickPathButton(
                        title: "Start Here",
                        systemImage: "figure.walk",
                        action: { onSelect(.startHere) }
                    )
                }

                HStack(spacing: LearnQuickPathLayout.buttonSpacing) {
                    LearnQuickPathButton(
                        title: "What Changes",
                        systemImage: "calendar.badge.clock",
                        action: { onSelect(.whatChanges) }
                    )
                    LearnQuickPathButton(
                        title: "Responses",
                        systemImage: "text.book.closed",
                        action: { onSelect(.pronunciation) }
                    )
                }
            }
        }
    }
}

private struct LearnQuickPathButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.referenceFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.92), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct LearnIntroCard: View {
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
                    message: """
                    Practical confidence is enough. If you can rejoin the broad movement of the rite calmly, \
                    the app is doing its work.
                    """
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

struct VoicesOfTraditionSection: View {
    var body: some View {
        LearnSectionCard(
            title: "Voices of the Tradition",
            subtitle: "A few short lines that help set the tone without turning the app into a quotation wall.",
            style: .inset
        ) {
            ForEach(traditionQuotes) { quote in
                LearnRowContainer(style: .tool) {
                    Text("\"\(quote.text)\"")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("learn-quote-\(quote.id)")

                    Text(quote.attribution)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.burgundy)
                }
            }
        }
    }
}

struct SupportLearnSection: View {
    let supportTipJar: SupportTipJar

    var body: some View {
        LearnSectionCard(
            title: "Optional Support",
            subtitle: "If this companion has served you well, you can leave a simple in-app tip to support its continued care.",
            style: .tool
        ) {
            Text("Tips are entirely optional. They do not unlock content, and the app remains fully usable without them.")
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
                    SupportTipOptionRow(option: option, supportTipJar: supportTipJar)
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
}

private struct SupportTipOptionRow: View {
    let option: SupportTipOption
    let supportTipJar: SupportTipJar

    var body: some View {
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
}
