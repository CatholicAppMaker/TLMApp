import SwiftUI

enum AppTheme {
    static let burgundy = Color(red: 0.39, green: 0.09, blue: 0.14)
    static let gold = Color(red: 0.71, green: 0.57, blue: 0.25)
    static let brass = Color(red: 0.58, green: 0.46, blue: 0.22)
    static let parchment = Color(red: 0.97, green: 0.94, blue: 0.87)
    static let parchmentShadow = Color(red: 0.90, green: 0.86, blue: 0.78)
    static let surface = Color(red: 0.99, green: 0.97, blue: 0.93)
    static let secondarySurface = Color(red: 0.95, green: 0.92, blue: 0.85)
    static let border = Color(red: 0.82, green: 0.76, blue: 0.66)
    static let ink = Color(red: 0.17, green: 0.14, blue: 0.11)
    static let mutedInk = Color(red: 0.36, green: 0.31, blue: 0.26)
    static let divider = border.opacity(0.9)
    static let background = parchment
    static let cardShadow = burgundy.opacity(0.08)

    static var backgroundWash: some ShapeStyle {
        LinearGradient(
            colors: [parchment, parchmentShadow.opacity(0.82)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardFill: some ShapeStyle {
        LinearGradient(
            colors: [surface, parchment.opacity(0.92)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
