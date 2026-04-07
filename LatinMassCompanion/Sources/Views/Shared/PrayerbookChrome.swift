import SwiftUI

enum PrayerbookPanelStyle {
    case standard
    case hero
    case tool
    case inset
}

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
    let style: PrayerbookPanelStyle

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .padding(panelPadding)
            .background(
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                    .fill(panelFill)
            )
            .overlay(alignment: .top) {
                topTint
            }
            .overlay(
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                    .stroke(panelStroke, lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
                    .stroke(topStroke, lineWidth: 1)
                    .padding(1)
                    .mask(alignment: .top) {
                        Rectangle()
                            .frame(height: topStrokeHeight)
                    }
            }
            .overlay(alignment: .topLeading) {
                topAccent
            }
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowYOffset)
    }

    private var panelFill: AnyShapeStyle {
        switch style {
        case .standard:
            AnyShapeStyle(AppTheme.cardFill)
        case .hero:
            AnyShapeStyle(AppTheme.heroFill)
        case .tool:
            AnyShapeStyle(AppTheme.toolFill)
        case .inset:
            AnyShapeStyle(AppTheme.referenceFill)
        }
    }

    private var panelStroke: Color {
        switch style {
        case .hero:
            AppTheme.burgundy.opacity(0.28)
        case .tool:
            AppTheme.gold.opacity(0.32)
        case .standard, .inset:
            AppTheme.border
        }
    }

    private var topStroke: Color {
        switch style {
        case .hero:
            AppTheme.gold.opacity(0.42)
        case .tool:
            AppTheme.burgundy.opacity(0.28)
        case .standard, .inset:
            AppTheme.burgundy.opacity(0.14)
        }
    }

    private var panelCornerRadius: CGFloat {
        switch style {
        case .hero:
            18
        case .tool:
            16
        case .standard, .inset:
            12
        }
    }

    private var panelPadding: CGFloat {
        switch style {
        case .hero:
            20
        case .tool:
            18
        case .standard, .inset:
            18
        }
    }

    private var topStrokeHeight: CGFloat {
        switch style {
        case .hero:
            14
        case .tool:
            12
        case .standard, .inset:
            10
        }
    }

    private var shadowColor: Color {
        switch style {
        case .hero:
            AppTheme.cardShadow.opacity(1.2)
        case .tool:
            AppTheme.cardShadow.opacity(0.95)
        case .standard, .inset:
            AppTheme.cardShadow
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .hero:
            16
        case .tool:
            10
        case .standard, .inset:
            8
        }
    }

    private var shadowYOffset: CGFloat {
        switch style {
        case .hero:
            8
        case .tool:
            5
        case .standard, .inset:
            3
        }
    }

    private var topTint: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: topTintColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: topTintHeight)
            .mask(alignment: .top) {
                RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
            }
    }

    private var topAccent: some View {
        HStack(spacing: 5) {
            DiamondMark()
                .fill(accentDiamondColor)
                .frame(width: accentDiamondSize, height: accentDiamondSize)
            Rectangle()
                .fill(accentLineColor)
                .frame(width: accentLineWidth, height: 1)
        }
        .padding(.top, accentTopPadding)
        .padding(.leading, accentLeadingPadding)
        .accessibilityHidden(true)
    }

    private var topTintColors: [Color] {
        switch style {
        case .hero:
            [
                AppTheme.burgundy.opacity(0.22),
                AppTheme.gold.opacity(0.16),
                AppTheme.roseMist.opacity(0.12),
                .clear
            ]
        case .tool:
            [
                AppTheme.gold.opacity(0.14),
                AppTheme.burgundy.opacity(0.12),
                .clear
            ]
        case .inset:
            [
                AppTheme.gold.opacity(0.1),
                AppTheme.secondarySurface.opacity(0.08),
                .clear
            ]
        case .standard:
            [
                AppTheme.burgundy.opacity(0.12),
                AppTheme.gold.opacity(0.08),
                .clear
            ]
        }
    }

    private var topTintHeight: CGFloat {
        switch style {
        case .hero:
            34
        case .tool:
            26
        case .standard, .inset:
            22
        }
    }

    private var accentDiamondColor: Color {
        switch style {
        case .hero:
            AppTheme.gold.opacity(0.95)
        case .tool:
            AppTheme.burgundy.opacity(0.75)
        case .standard, .inset:
            AppTheme.gold.opacity(0.85)
        }
    }

    private var accentLineColor: Color {
        switch style {
        case .hero:
            AppTheme.burgundy.opacity(0.35)
        case .tool:
            AppTheme.gold.opacity(0.34)
        case .standard, .inset:
            AppTheme.burgundy.opacity(0.22)
        }
    }

    private var accentDiamondSize: CGFloat {
        style == .hero ? 8 : 7
    }

    private var accentLineWidth: CGFloat {
        switch style {
        case .hero:
            44
        case .tool:
            28
        case .standard, .inset:
            34
        }
    }

    private var accentTopPadding: CGFloat {
        switch style {
        case .hero:
            12
        case .tool:
            11
        case .standard, .inset:
            10
        }
    }

    private var accentLeadingPadding: CGFloat {
        switch style {
        case .hero:
            14
        case .tool:
            13
        case .standard, .inset:
            12
        }
    }
}

extension View {
    func prayerbookPanel(style: PrayerbookPanelStyle = .standard) -> some View {
        modifier(PrayerbookPanelModifier(style: style))
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
    var compact = false

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.burgundy)

                Text(title)
                    .font(.system(compact ? .title3 : .title3, design: .serif).weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(compact ? 3 : nil)

                Text(subtitle)
                    .font(compact ? .callout : .subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(compact ? 4 : nil)

                if let caption {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(AppTheme.burgundy)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(compact ? 2 : nil)
                }
            }

            Spacer(minLength: 8)

            LiturgicalMotif(kind: kind)
                .frame(width: compact ? 72 : 90, height: compact ? 60 : 74)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .topTrailing) {
            LiturgicalHeroBackdrop(kind: kind)
                .frame(width: compact ? 88 : 110, height: compact ? 66 : 84)
                .padding(.trailing, compact ? 8 : 2)
                .padding(.top, compact ? 8 : 4)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        }
        .prayerbookPanel(style: .hero)
    }
}

private struct LiturgicalHeroBackdrop: View {
    let kind: LiturgicalMotifKind

    private var glowColor: Color {
        switch kind {
        case .guide:
            AppTheme.burgundy
        case .calendar:
            AppTheme.gold
        case .learn:
            AppTheme.ember
        }
    }

    private var haloColor: Color {
        switch kind {
        case .guide:
            AppTheme.gold
        case .calendar:
            AppTheme.roseMist
        case .learn:
            AppTheme.gold
        }
    }

    private var symbolName: String {
        switch kind {
        case .guide:
            "book.pages.fill"
        case .calendar:
            "calendar"
        case .learn:
            "music.note"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(glowColor.opacity(0.06))
                .frame(width: 82, height: 82)
                .offset(x: 14, y: -6)

            Circle()
                .fill(haloColor.opacity(0.08))
                .frame(width: 58, height: 58)
                .offset(x: -10, y: 10)

            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(glowColor.opacity(0.10), lineWidth: 1)
                .frame(width: 82, height: 48)
                .rotationEffect(.degrees(-14))
                .offset(x: 14, y: 8)

            Circle()
                .trim(from: 0.08, to: 0.84)
                .stroke(haloColor.opacity(0.22), style: StrokeStyle(lineWidth: 1.25, lineCap: .round))
                .frame(width: 74, height: 74)
                .rotationEffect(.degrees(-32))
                .offset(x: 12, y: -2)

            Image(systemName: symbolName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(glowColor.opacity(0.16))
                .offset(x: 16, y: 0)
        }
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
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowYOffset)
    }

    private var backgroundColor: Color {
        switch tone {
        case .accent:
            AppTheme.burgundyHighlight
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
            AppTheme.burgundy.opacity(0.22)
        case .neutral:
            AppTheme.border
        }
    }

    private var borderWidth: CGFloat {
        switch tone {
        case .accent:
            1
        case .neutral:
            1
        }
    }

    private var shadowColor: Color {
        switch tone {
        case .accent:
            AppTheme.burgundy.opacity(0.18)
        case .neutral:
            .clear
        }
    }

    private var shadowRadius: CGFloat {
        tone == .accent ? 6 : 0
    }

    private var shadowYOffset: CGFloat {
        tone == .accent ? 2 : 0
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

    private var upperGlowColor: Color {
        switch kind {
        case .guide:
            AppTheme.gold
        case .calendar:
            AppTheme.roseMist
        case .learn:
            AppTheme.ember
        }
    }

    private var lowerGlowColor: Color {
        switch kind {
        case .guide:
            AppTheme.burgundy
        case .calendar:
            AppTheme.gold
        case .learn:
            AppTheme.burgundy
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.toolFill)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.border.opacity(0.9), lineWidth: 1)

            Circle()
                .fill(upperGlowColor.opacity(0.16))
                .frame(width: 72, height: 72)
                .offset(x: -20, y: 10)

            Circle()
                .fill(lowerGlowColor.opacity(0.12))
                .frame(width: 54, height: 54)
                .offset(x: 24, y: -16)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(upperGlowColor.opacity(0.18), lineWidth: 1)
                .frame(width: 86, height: 54)
                .rotationEffect(.degrees(-18))
                .offset(x: 14, y: 18)

            Circle()
                .trim(from: 0.12, to: 0.88)
                .stroke(lowerGlowColor.opacity(0.22), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(18))
                .offset(x: -16, y: -10)

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
