import SwiftUI

enum Theme {
    // MARK: - Colors
    enum Palette {
        /// Warm cream page background
        static let background = Color(red: 254/255, green: 249/255, blue: 242/255)
        /// Slightly deeper surface (cards, containers)
        static let surface = Color(red: 244/255, green: 239/255, blue: 231/255)
        /// Even deeper for subtle contrast
        static let surfaceDeep = Color(red: 235/255, green: 228/255, blue: 216/255)
        /// Primary ink — dark brown
        static let ink = Color(red: 68/255, green: 42/255, blue: 34/255)
        /// Secondary text — muted brown
        static let muted = Color(red: 118/255, green: 96/255, blue: 87/255)
        /// Warm brown accent
        static let accent = Color(red: 119/255, green: 87/255, blue: 77/255)
        /// Soft olive/sage for dots, outlines
        static let sage = Color(red: 127/255, green: 132/255, blue: 84/255)
        /// Ruled-paper line color
        static let rule = Color(red: 184/255, green: 189/255, blue: 136/255).opacity(0.35)
    }

    // MARK: - Fonts
    enum Fonts {
        /// Elegant serif — for questions, dates
        static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .serif)
        }

        /// Italic serif — for emphasis, quoted text
        static func serifItalic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .custom("NewYork-RegularItalic", size: size).weight(weight)
        }

        /// Typewriter — for body answers, journal entries
        static func typewriter(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .custom("AmericanTypewriter", size: size).weight(weight)
        }

        /// Elegant cursive — for branding, titles
        static func cursive(_ size: CGFloat) -> Font {
            .custom("SnellRoundhand-Bold", size: size)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
}

// MARK: - View modifiers

extension View {
    /// Apply the themed page background
    func themedBackground() -> some View {
        self.background(Theme.Palette.background.ignoresSafeArea())
    }
}
