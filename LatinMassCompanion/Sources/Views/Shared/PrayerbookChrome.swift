import SwiftUI

struct LiturgicalRule: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(AppTheme.divider)
                .frame(height: 1)

            DiamondMark()
                .fill(AppTheme.gold.opacity(0.75))
                .frame(width: 8, height: 8)

            Rectangle()
                .fill(AppTheme.divider)
                .frame(height: 1)
        }
        .accessibilityHidden(true)
    }
}

struct PrayerbookPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.cardFill)
            )
            .overlay(alignment: .top) {
                topTint
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.burgundy.opacity(0.14), lineWidth: 1)
                    .padding(1)
                    .mask(alignment: .top) {
                        Rectangle()
                            .frame(height: 10)
                    }
            }
            .overlay(alignment: .topLeading) {
                topAccent
            }
            .shadow(color: AppTheme.cardShadow, radius: 8, y: 3)
    }

    private var topTint: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        AppTheme.burgundy.opacity(0.12),
                        AppTheme.gold.opacity(0.08),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 22)
            .mask(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
            }
    }

    private var topAccent: some View {
        HStack(spacing: 5) {
            DiamondMark()
                .fill(AppTheme.gold.opacity(0.85))
                .frame(width: 7, height: 7)
            Rectangle()
                .fill(AppTheme.burgundy.opacity(0.22))
                .frame(width: 34, height: 1)
        }
        .padding(.top, 10)
        .padding(.leading, 12)
        .accessibilityHidden(true)
    }
}

extension View {
    func prayerbookPanel() -> some View {
        modifier(PrayerbookPanelModifier())
    }
}

enum LiturgicalMotifKind {
    case guide
    case calendar
    case learn
}

struct LiturgicalHeroPanel: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let kind: LiturgicalMotifKind
    var caption: String?

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)

                Text(title)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(AppTheme.ink)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)

                if let caption {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(AppTheme.burgundy)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            LiturgicalMotif(kind: kind)
                .frame(width: 116, height: 96)
                .accessibilityHidden(true)
        }
        .prayerbookPanel()
    }
}

struct LiturgicalMotifBadge: View {
    let kind: LiturgicalMotifKind

    var body: some View {
        LiturgicalMotif(kind: kind)
            .frame(width: 74, height: 74)
    }
}

enum PrayerbookBadgeTone {
    case accent
    case neutral
}

struct PrayerbookBadge: View {
    let title: String
    let tone: PrayerbookBadgeTone

    init(title: String, tone: PrayerbookBadgeTone = .neutral) {
        self.title = title
        self.tone = tone
    }

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    private var backgroundColor: Color {
        switch tone {
        case .accent:
            AppTheme.burgundy
        case .neutral:
            AppTheme.secondarySurface
        }
    }

    private var foregroundColor: Color {
        switch tone {
        case .accent:
            AppTheme.surface
        case .neutral:
            AppTheme.ink
        }
    }

    private var borderColor: Color {
        switch tone {
        case .accent:
            .clear
        case .neutral:
            AppTheme.border
        }
    }

    private var borderWidth: CGFloat {
        switch tone {
        case .accent:
            0
        case .neutral:
            1
        }
    }
}

struct SourceAttributionLine: View {
    let references: [SourceReference]

    var body: some View {
        if !references.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Anchored by \(references.map(\.title).joined(separator: " • "))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Anchored by \(references.map(\.title).joined(separator: ", "))"
            )
        }
    }
}

private struct LiturgicalMotif: View {
    let kind: LiturgicalMotifKind

    private var leadingSymbol: String {
        switch kind {
        case .guide:
            "book.pages.fill"
        case .calendar:
            "calendar"
        case .learn:
            "music.note"
        }
    }

    private var trailingSymbol: String {
        switch kind {
        case .guide:
            "bookmark.fill"
        case .calendar:
            "book.closed.fill"
        case .learn:
            "text.book.closed.fill"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.secondarySurface.opacity(0.82))

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.border.opacity(0.9), lineWidth: 1)

            Circle()
                .fill(AppTheme.gold.opacity(0.16))
                .frame(width: 72, height: 72)
                .offset(x: -20, y: 10)

            Circle()
                .fill(AppTheme.burgundy.opacity(0.12))
                .frame(width: 54, height: 54)
                .offset(x: 24, y: -16)

            VStack(spacing: 10) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(AppTheme.burgundy)

                HStack(spacing: 10) {
                    motifSymbol(leadingSymbol)
                    motifSymbol(trailingSymbol)
                }
            }

            VStack {
                HStack {
                    Rectangle()
                        .fill(AppTheme.gold.opacity(0.6))
                        .frame(width: 30, height: 1)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(AppTheme.burgundy.opacity(0.4))
                        .frame(width: 26, height: 1)
                }
            }
            .padding(16)
        }
    }

    private func motifSymbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppTheme.gold)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(AppTheme.surface.opacity(0.85))
            )
    }
}

private struct DiamondMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
