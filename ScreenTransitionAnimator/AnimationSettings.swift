import SwiftUI

class AnimationSettings: ObservableObject {
    @Published var primaryColor: Color = .cyan
    @Published var secondaryColor: Color = .blue
    @Published var accentColor: Color = .white
    @Published var animationStyle: AnimationStyle = .radialBurst
    @Published var animationDuration: Double = 0.6
    @Published var flashThickness: CGFloat = 20
    @Published var showArrow: Bool = true
    @Published var showParticles: Bool = true

    enum AnimationStyle: String, CaseIterable {
        case radialBurst = "Radial Burst"
        case linearWave = "Linear Wave"
        case pulse = "Pulse"
        case ripple = "Ripple"
    }
}
