import SwiftUI

extension Color {
  init(hex: UInt) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}

enum EC {
  static let background = Color(hex: 0x08080C)
  static let card = Color(hex: 0x121218)
  static let elevated = Color(hex: 0x1A1A22)
  static let border = Color.white.opacity(0.08)
  static let accent = Color(hex: 0xF5A623)
  static let success = Color(hex: 0x42D77D)

  // Compatibility alias for the existing views.
  static let bg = background
}
