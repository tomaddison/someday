import SwiftUI

extension Font {
    static func serifItalic(_ size: CGFloat) -> Font {
        Font.custom("EBGaramond-SemiBold", size: size).italic()
    }

    // EB Garamond - display and headline type
    static let somedayDisplay = Font.custom("EBGaramond-SemiBold", size: 36)
    static let somedayTitle = Font.custom("EBGaramond-SemiBold", size: 28)
    static let somedayHeadline = Font.custom("EBGaramond-SemiBold", size: 22)

    // HarmonyOS Sans - body and UI type
    static let somedayDetailTitle = Font.custom("HarmonyOS_Sans_Bold", size: 22)
    static let somedayBody = Font.custom("HarmonyOS_Sans", size: 17)
    static let somedayCaption = Font.custom("HarmonyOS_Sans", size: 13)
    static let somedaySmall = Font.custom("HarmonyOS_Sans", size: 11)
}
