import SwiftUI

extension Color {
    static let cream = Color(hex: "F7F4F3")
    static let nearBlack = Color(hex: "0F1216")
    static let midnight = Color(hex: "05051B")
    static let nightSky = Color(hex: "0A0F2E")
    static let starWhite = Color(hex: "F5F0E8")
    static let starDim = Color(hex: "8B8FA8")
    static let sun = Color(hex: "F6C392")
    static let blush = Color(hex: "F2BFC0")
    static let sage = Color(hex: "CFE2A4")
    static let lavender = Color(hex: "CFB8E9")
    static let dust = Color(hex: "D4C4BF")

    static let peach = Color(hex: "F8C4A4")
    static let sky = Color(hex: "A4CBE2")
    static let mint = Color(hex: "A4E2C8")
    static let coral = Color(hex: "E89B9B")
    static let butter = Color(hex: "EDE4A1")

    static let somedayPalette: [Color] = [.blush, .sage, .lavender, .peach, .sky, .mint, .coral, .butter]
    static let somedayPaletteHex: [String] = ["#F2BFC0", "#CFE2A4", "#CFB8E9", "#F8C4A4", "#A4CBE2", "#A4E2C8", "#E89B9B", "#EDE4A1"]

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func softShift(by amount: CGFloat) -> Color {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(
            hue: Double((h + amount).truncatingRemainder(dividingBy: 1.0)),
            saturation: Double(min(s * 1.15, 1.0)),
            brightness: Double(b),
            opacity: Double(a)
        )
    }
}
