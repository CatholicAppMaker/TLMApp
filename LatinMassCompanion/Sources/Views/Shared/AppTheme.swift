import SwiftUI

enum AppTheme {
    static let burgundy = dynamicColor(
        light: Palette(0.39, 0.09, 0.14),
        dark: Palette(0.79, 0.45, 0.50)
    )
    static let burgundyHighlight = dynamicColor(
        light: Palette(0.52, 0.17, 0.21),
        dark: Palette(0.89, 0.62, 0.66)
    )
    static let gold = dynamicColor(
        light: Palette(0.71, 0.57, 0.25),
        dark: Palette(0.83, 0.72, 0.43)
    )
    static let brass = dynamicColor(
        light: Palette(0.58, 0.46, 0.22),
        dark: Palette(0.75, 0.63, 0.35)
    )
    static let parchment = dynamicColor(
        light: Palette(0.97, 0.94, 0.87),
        dark: Palette(0.12, 0.11, 0.10)
    )
    static let parchmentShadow = dynamicColor(
        light: Palette(0.91, 0.87, 0.80),
        dark: Palette(0.16, 0.15, 0.14)
    )
    static let surface = dynamicColor(
        light: Palette(0.99, 0.98, 0.95),
        dark: Palette(0.17, 0.15, 0.14)
    )
    static let secondarySurface = dynamicColor(
        light: Palette(0.95, 0.92, 0.86),
        dark: Palette(0.21, 0.19, 0.18)
    )
    static let tertiarySurface = dynamicColor(
        light: Palette(0.93, 0.89, 0.82),
        dark: Palette(0.26, 0.23, 0.21)
    )
    static let border = dynamicColor(
        light: Palette(0.80, 0.74, 0.65),
        dark: Palette(0.39, 0.34, 0.29)
    )
    static let ink = dynamicColor(
        light: Palette(0.17, 0.14, 0.11),
        dark: Palette(0.94, 0.91, 0.86)
    )
    static let mutedInk = dynamicColor(
        light: Palette(0.34, 0.29, 0.24),
        dark: Palette(0.77, 0.72, 0.67)
    )
    static let divider = border.opacity(0.9)
    static let background = parchment
    static let cardShadow = Color(
        uiColor: UIColor { trait in
            UIColor(
                white: 0,
                alpha: trait.userInterfaceStyle == .dark ? 0.32 : 0.05
            )
        }
    )

    static var backgroundWash: some ShapeStyle {
        LinearGradient(
            colors: [parchment, parchmentShadow.opacity(0.75), surface.opacity(0.96)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardFill: some ShapeStyle {
        LinearGradient(
            colors: [surface, parchment.opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var insetPanelFill: some ShapeStyle {
        LinearGradient(
            colors: [secondarySurface.opacity(0.92), parchment.opacity(0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private static func dynamicColor(
        light: Palette,
        dark: Palette
    ) -> Color {
        Color(
            uiColor: UIColor { trait in
                let palette = trait.userInterfaceStyle == .dark ? dark : light
                return UIColor(
                    red: palette.red,
                    green: palette.green,
                    blue: palette.blue,
                    alpha: 1
                )
            }
        )
    }
}

private struct Palette {
    let red: Double
    let green: Double
    let blue: Double

    init(_ red: Double, _ green: Double, _ blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}
