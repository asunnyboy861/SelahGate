import SwiftUI

public enum Theme {
    public static let porcelain = Color(uiColor: .init { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.071, green: 0.063, blue: 0.055, alpha: 1)
        : UIColor(red: 0.969, green: 0.953, blue: 0.925, alpha: 1)
    })

    public static let card = Color(uiColor: .init { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.11, green: 0.098, blue: 0.09, alpha: 0.7)
        : UIColor.white.withAlphaComponent(0.6)
    })

    public static let gold = Color(uiColor: .init { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.851, green: 0.659, blue: 0.369, alpha: 1)
        : UIColor(red: 0.706, green: 0.533, blue: 0.294, alpha: 1)
    })

    public static let sage = Color(uiColor: .init { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.616, green: 0.706, blue: 0.541, alpha: 1)
        : UIColor(red: 0.49, green: 0.561, blue: 0.412, alpha: 1)
    })

    public static let dawnTop = Color(uiColor: .init { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.165, green: 0.129, blue: 0.094, alpha: 1)
        : UIColor(red: 0.992, green: 0.941, blue: 0.867, alpha: 1)
    })

    public static let dawnBottom = Color(uiColor: .init { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.29, green: 0.227, blue: 0.133, alpha: 1)
        : UIColor(red: 0.918, green: 0.788, blue: 0.561, alpha: 1)
    })

    public static var dawn: some View {
        LinearGradient(colors: [dawnTop, dawnBottom], startPoint: .top, endPoint: .bottom)
    }

    public static let serifTitle = Font.system(.title, design: .serif).weight(.bold)
    public static let serifLarge = Font.system(.title2, design: .serif)
    public static let serifVerse = Font.system(.title3, design: .serif).weight(.medium)
}
