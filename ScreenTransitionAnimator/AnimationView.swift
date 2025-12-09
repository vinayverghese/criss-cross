import SwiftUI

struct AnimationView: View {
    @Binding var shouldAnimate: Bool
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.3)

            // Animated circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.cyan, .blue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)

            // Particle effects
            ForEach(0..<8) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(
                        x: shouldAnimate ? cos(Double(index) * .pi / 4) * 100 : 0,
                        y: shouldAnimate ? sin(Double(index) * .pi / 4) * 100 : 0
                    )
                    .opacity(shouldAnimate ? 0 : 1)
            }
        }
        .cornerRadius(12)
        .onChange(of: shouldAnimate) { newValue in
            if newValue {
                performAnimation()
            }
        }
    }

    private func performAnimation() {
        // Reset values
        scale = 1.0
        rotation = 0
        opacity = 1.0

        // Animate with spring effect
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.5
        }

        withAnimation(.linear(duration: 0.8)) {
            rotation = 360
        }

        withAnimation(.easeInOut(duration: 0.4)) {
            opacity = 0.5
        }

        // Return to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
