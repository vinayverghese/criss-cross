import SwiftUI

class AnimationSettings: ObservableObject {
    @Published var primaryColor: Color {
        didSet { saveColor(primaryColor, key: "primaryColor") }
    }
    @Published var secondaryColor: Color {
        didSet { saveColor(secondaryColor, key: "secondaryColor") }
    }
    @Published var accentColor: Color {
        didSet { saveColor(accentColor, key: "accentColor") }
    }
    @Published var animationStyle: AnimationStyle {
        didSet { UserDefaults.standard.set(animationStyle.rawValue, forKey: "animationStyle") }
    }
    @Published var animationDuration: Double {
        didSet { UserDefaults.standard.set(animationDuration, forKey: "animationDuration") }
    }
    @Published var flashThickness: CGFloat {
        didSet { UserDefaults.standard.set(flashThickness, forKey: "flashThickness") }
    }
    @Published var showArrow: Bool {
        didSet { UserDefaults.standard.set(showArrow, forKey: "showArrow") }
    }
    @Published var showParticles: Bool {
        didSet { UserDefaults.standard.set(showParticles, forKey: "showParticles") }
    }

    enum AnimationStyle: String, CaseIterable, Codable {
        case radialBurst = "Radial Burst"
        case linearWave = "Linear Wave"
        case pulse = "Pulse"
        case ripple = "Ripple"
    }

    init() {
        // Load saved values or use defaults
        self.primaryColor = Self.loadColor(key: "primaryColor", default: .cyan)
        self.secondaryColor = Self.loadColor(key: "secondaryColor", default: .blue)
        self.accentColor = Self.loadColor(key: "accentColor", default: .white)

        if let styleString = UserDefaults.standard.string(forKey: "animationStyle"),
            let style = AnimationStyle(rawValue: styleString)
        {
            self.animationStyle = style
        } else {
            self.animationStyle = .radialBurst
        }

        let duration = UserDefaults.standard.double(forKey: "animationDuration")
        self.animationDuration = duration > 0 ? duration : 0.6

        let thickness = UserDefaults.standard.double(forKey: "flashThickness")
        self.flashThickness = thickness > 0 ? CGFloat(thickness) : 20

        self.showArrow = UserDefaults.standard.object(forKey: "showArrow") as? Bool ?? true
        self.showParticles = UserDefaults.standard.object(forKey: "showParticles") as? Bool ?? true
    }

    private func saveColor(_ color: Color, key: String) {
        if let components = NSColor(color).cgColor.components, components.count >= 3 {
            UserDefaults.standard.set([components[0], components[1], components[2]], forKey: key)
        }
    }

    private static func loadColor(key: String, default defaultColor: Color) -> Color {
        if let components = UserDefaults.standard.array(forKey: key) as? [CGFloat],
            components.count >= 3
        {
            return Color(red: components[0], green: components[1], blue: components[2])
        }
        return defaultColor
    }
}
