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
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: AppTheme.cardShadow, radius: 14, y: 6)
    }
}

extension View {
    func prayerbookPanel() -> some View {
        modifier(PrayerbookPanelModifier())
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
