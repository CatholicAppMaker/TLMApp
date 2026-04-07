import SwiftUI

struct LiturgicalHeroBackdrop: View {
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
                .stroke(
                    haloColor.opacity(0.22),
                    style: StrokeStyle(lineWidth: 1.25, lineCap: .round)
                )
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
            .accessibilityLabel("Anchored by \(references.map(\.title).joined(separator: ", "))")
        }
    }
}

struct LiturgicalMotif: View {
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
                .stroke(
                    lowerGlowColor.opacity(0.22),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
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

struct DiamondMark: Shape {
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
