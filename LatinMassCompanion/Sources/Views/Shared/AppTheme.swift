import SwiftUI

enum AppTheme {
    static let burgundy = Color(red: 0.39, green: 0.09, blue: 0.14)
    static let burgundyHighlight = Color(red: 0.52, green: 0.17, blue: 0.21)
    static let gold = Color(red: 0.71, green: 0.57, blue: 0.25)
    static let brass = Color(red: 0.58, green: 0.46, blue: 0.22)
    static let parchment = Color(red: 0.97, green: 0.94, blue: 0.87)
    static let parchmentShadow = Color(red: 0.91, green: 0.87, blue: 0.80)
    static let surface = Color(red: 0.99, green: 0.98, blue: 0.95)
    static let secondarySurface = Color(red: 0.95, green: 0.92, blue: 0.86)
    static let tertiarySurface = Color(red: 0.93, green: 0.89, blue: 0.82)
    static let border = Color(red: 0.80, green: 0.74, blue: 0.65)
    static let ink = Color(red: 0.17, green: 0.14, blue: 0.11)
    static let mutedInk = Color(red: 0.34, green: 0.29, blue: 0.24)
    static let divider = border.opacity(0.9)
    static let background = parchment
    static let cardShadow = Color.black.opacity(0.05)

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
}
