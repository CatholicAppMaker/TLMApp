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
