import SwiftUI

enum AppTheme {
    static let burgundy = Color(red: 0.42, green: 0.10, blue: 0.16)
    static let gold = Color(red: 0.76, green: 0.63, blue: 0.31)
    static let parchment = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let parchmentShadow = Color(red: 0.93, green: 0.90, blue: 0.84)
    static let surface = Color(red: 0.99, green: 0.98, blue: 0.95)
    static let secondarySurface = Color.white.opacity(0.82)
    static let border = Color(red: 0.84, green: 0.79, blue: 0.72)
    static let ink = Color(red: 0.19, green: 0.16, blue: 0.14)
    static let mutedInk = Color(red: 0.39, green: 0.33, blue: 0.29)
    static let divider = border.opacity(0.9)
    static let background = parchment
}
