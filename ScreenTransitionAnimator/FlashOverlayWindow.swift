import Cocoa
import SwiftUI

struct AnimationConfig {
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let animationStyle: AnimationSettings.AnimationStyle
    let animationDuration: Double
    let flashThickness: CGFloat
    let showArrow: Bool
    let showParticles: Bool

    init(from settings: AnimationSettings?) {
        self.primaryColor = settings?.primaryColor ?? Color(red: 0, green: 1, blue: 1)
        self.secondaryColor = settings?.secondaryColor ?? .blue
        self.accentColor = settings?.accentColor ?? .white
        self.animationStyle = settings?.animationStyle ?? .radialBurst
        self.animationDuration = settings?.animationDuration ?? 0.6
        self.flashThickness = settings?.flashThickness ?? 20
        self.showArrow = settings?.showArrow ?? true
        self.showParticles = settings?.showParticles ?? true
    }
}

class FlashOverlayWindow: NSWindow {
    var config: AnimationConfig

    init(settings: AnimationSettings? = nil) {
        self.config = AnimationConfig(from: settings)
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.hasShadow = false
    }

    func showFlash(
        at position: NSPoint, direction: TransitionDirection, completion: (() -> Void)? = nil
    ) {
        let hostingView = NSHostingView(
            rootView: FlashAnimationView(direction: direction, config: config)
        )
        self.contentView = hostingView

        // Position window at cursor
        let size = CGSize(width: 200, height: 200)
        let origin = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
        self.setFrame(NSRect(origin: origin, size: size), display: true)

        self.orderFrontRegardless()
        self.alphaValue = 1.0

        let duration = config.animationDuration

        // Fade out and close
        NSAnimationContext.runAnimationGroup(
            { [weak self] context in
                context.duration = duration
                self?.animator().alphaValue = 0.0
            },
            completionHandler: { [weak self] in
                self?.orderOut(nil)
                self?.contentView = nil
                completion?()
            })
    }

    func showEdgeFlash(edge: NSRectEdge, screen: NSScreen, completion: (() -> Void)? = nil) {
        let hostingView = NSHostingView(rootView: EdgeFlashView(edge: edge, config: config))
        self.contentView = hostingView

        let screenFrame = screen.frame
        var flashFrame: NSRect
        let thickness = config.flashThickness

        switch edge {
        case .minX:  // Left edge
            flashFrame = NSRect(
                x: screenFrame.minX, y: screenFrame.minY, width: thickness,
                height: screenFrame.height)
        case .maxX:  // Right edge
            flashFrame = NSRect(
                x: screenFrame.maxX - thickness, y: screenFrame.minY, width: thickness,
                height: screenFrame.height
            )
        case .minY:  // Bottom edge
            flashFrame = NSRect(
                x: screenFrame.minX, y: screenFrame.minY, width: screenFrame.width,
                height: thickness)
        case .maxY:  // Top edge
            flashFrame = NSRect(
                x: screenFrame.minX, y: screenFrame.maxY - thickness, width: screenFrame.width,
                height: thickness)
        @unknown default:
            flashFrame = .zero
        }

        self.setFrame(flashFrame, display: true)
        self.orderFrontRegardless()
        self.alphaValue = 1.0

        let duration = config.animationDuration

        // Fade out
        NSAnimationContext.runAnimationGroup(
            { [weak self] context in
                context.duration = duration
                self?.animator().alphaValue = 0.0
            },
            completionHandler: { [weak self] in
                self?.orderOut(nil)
                self?.contentView = nil
                completion?()
            })
    }
}

enum TransitionDirection {
    case left, right, up, down, unknown
}

struct FlashAnimationView: View {
    let direction: TransitionDirection
    let config: AnimationConfig
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var particleOffsets: [CGFloat] = Array(repeating: 0, count: 8)

    var body: some View {
        ZStack {
            // Background animation based on style
            animationBackground

            // Particles
            if config.showParticles {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(config.accentColor)
                        .frame(width: 10, height: 10)
                        .offset(
                            x: cos(Double(index) * .pi / 4) * particleOffsets[index],
                            y: sin(Double(index) * .pi / 4) * particleOffsets[index]
                        )
                        .opacity(
                            particleOffsets[index] > 0
                                ? 1 - Double(particleOffsets[index] / 100) : 0)
                }
            }

            // Directional arrow
            if config.showArrow {
                Image(systemName: arrowIcon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(config.accentColor)
                    .shadow(color: config.primaryColor, radius: 10)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            let duration = config.animationDuration

            withAnimation(.spring(response: duration * 0.5, dampingFraction: 0.5)) {
                scale = 2.0
            }
            withAnimation(.easeOut(duration: duration * 0.4)) {
                rotation = 360
            }

            // Animate particles
            if config.showParticles {
                for i in 0..<8 {
                    withAnimation(.easeOut(duration: duration).delay(Double(i) * 0.05)) {
                        particleOffsets[i] = 100
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var animationBackground: some View {
        switch config.animationStyle {
        case .radialBurst:
            radialBurstView(
                primary: config.primaryColor, secondary: config.secondaryColor,
                accent: config.accentColor)
        case .linearWave:
            linearWaveView(
                primary: config.primaryColor, secondary: config.secondaryColor,
                accent: config.accentColor)
        case .pulse:
            pulseView(primary: config.primaryColor, secondary: config.secondaryColor)
        case .ripple:
            rippleView(primary: config.primaryColor)
        }
    }

    private func radialBurstView(primary: Color, secondary: Color, accent: Color) -> some View {
        let colors = [
            accent.opacity(0.9),
            primary.opacity(0.6),
            secondary.opacity(0.3),
            Color.clear,
        ]
        return RadialGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
        .scaleEffect(scale)
    }

    private func linearWaveView(primary: Color, secondary: Color, accent: Color) -> some View {
        let colors = [
            accent.opacity(0.8),
            primary.opacity(0.6),
            secondary.opacity(0.4),
        ]
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
        .scaleEffect(scale)
    }

    private func pulseView(primary: Color, secondary: Color) -> some View {
        let gradient = RadialGradient(
            gradient: Gradient(colors: [primary, secondary]),
            center: .center,
            startRadius: 0,
            endRadius: 50
        )
        let opacity = 2 - scale
        return Circle()
            .fill(gradient)
            .scaleEffect(scale)
            .opacity(opacity)
    }

    private func rippleView(primary: Color) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                let scaleMultiplier = 1 + CGFloat(i) * 0.3
                let rippleScale = scale * scaleMultiplier
                let rippleOpacity = 1 - (scale - 0.5) * scaleMultiplier
                Circle()
                    .stroke(primary, lineWidth: 3)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
            }
        }
    }

    private var arrowIcon: String {
        switch direction {
        case .left: return "arrow.left.circle.fill"
        case .right: return "arrow.right.circle.fill"
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .unknown: return "circle.fill"
        }
    }
}

struct EdgeFlashView: View {
    let edge: NSRectEdge
    let config: AnimationConfig
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Solid bright flash
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            config.accentColor.opacity(0.9),
                            config.primaryColor.opacity(0.8),
                            config.secondaryColor.opacity(0.7),
                        ]),
                        startPoint: gradientStart,
                        endPoint: gradientEnd
                    )
                )

            // Glow effect
            Rectangle()
                .fill(config.primaryColor)
                .blur(radius: 10)
                .opacity(0.6)
        }
        .scaleEffect(
            isVertical ? CGSize(width: 1.0, height: scale) : CGSize(width: scale, height: 1.0)
        )
        .onAppear {
            let duration = config.animationDuration
            withAnimation(.easeOut(duration: duration * 0.7)) {
                scale = 0.3
            }
        }
    }

    private var isVertical: Bool {
        edge == .minX || edge == .maxX
    }

    private var gradientStart: UnitPoint {
        switch edge {
        case .minX: return .leading
        case .maxX: return .trailing
        case .minY: return .bottom
        case .maxY: return .top
        @unknown default: return .center
        }
    }

    private var gradientEnd: UnitPoint {
        switch edge {
        case .minX: return .trailing
        case .maxX: return .leading
        case .minY: return .top
        case .maxY: return .bottom
        @unknown default: return .center
        }
    }
}
