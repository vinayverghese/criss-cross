import Cocoa
import SwiftUI

class FlashOverlayWindow: NSWindow {
    var settings: AnimationSettings?

    init(settings: AnimationSettings? = nil) {
        self.settings = settings
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

    func showFlash(at position: NSPoint, direction: TransitionDirection) {
        let hostingView = NSHostingView(
            rootView: FlashAnimationView(direction: direction, settings: settings)
        )
        self.contentView = hostingView

        // Position window at cursor
        let size = CGSize(width: 200, height: 200)
        let origin = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
        self.setFrame(NSRect(origin: origin, size: size), display: true)

        self.orderFrontRegardless()
        self.alphaValue = 1.0

        let duration = settings?.animationDuration ?? 0.8

        // Fade out and close
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = duration
                self.animator().alphaValue = 0.0
            },
            completionHandler: {
                self.orderOut(nil)
            })
    }

    func showEdgeFlash(edge: NSRectEdge, screen: NSScreen) {
        let hostingView = NSHostingView(rootView: EdgeFlashView(edge: edge, settings: settings))
        self.contentView = hostingView

        let screenFrame = screen.frame
        var flashFrame: NSRect
        let thickness = settings?.flashThickness ?? 20

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

        let duration = settings?.animationDuration ?? 0.6

        // Fade out
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = duration
                self.animator().alphaValue = 0.0
            },
            completionHandler: {
                self.orderOut(nil)
            })
    }
}

enum TransitionDirection {
    case left, right, up, down, unknown
}

struct FlashAnimationView: View {
    let direction: TransitionDirection
    let settings: AnimationSettings?
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var particleOffsets: [CGFloat] = Array(repeating: 0, count: 8)

    var body: some View {
        ZStack {
            // Background animation based on style
            animationBackground

            // Particles
            if settings?.showParticles ?? true {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(settings?.accentColor ?? .white)
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
            if settings?.showArrow ?? true {
                Image(systemName: arrowIcon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(settings?.accentColor ?? .white)
                    .shadow(color: settings?.primaryColor ?? .cyan, radius: 10)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            let duration = settings?.animationDuration ?? 0.8

            withAnimation(.spring(response: duration * 0.5, dampingFraction: 0.5)) {
                scale = 2.0
            }
            withAnimation(.easeOut(duration: duration * 0.4)) {
                rotation = 360
            }

            // Animate particles
            if settings?.showParticles ?? true {
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
        let style = settings?.animationStyle ?? .radialBurst
        let primary = settings?.primaryColor ?? .cyan
        let secondary = settings?.secondaryColor ?? .blue
        let accent = settings?.accentColor ?? .white

        switch style {
        case .radialBurst:
            RadialGradient(
                gradient: Gradient(colors: [
                    accent.opacity(0.9),
                    primary.opacity(0.6),
                    secondary.opacity(0.3),
                    Color.clear,
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 100
            )
            .scaleEffect(scale)

        case .linearWave:
            LinearGradient(
                gradient: Gradient(colors: [
                    accent.opacity(0.8),
                    primary.opacity(0.6),
                    secondary.opacity(0.4),
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .scaleEffect(scale)

        case .pulse:
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [primary, secondary]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .scaleEffect(scale)
                .opacity(2 - scale)

        case .ripple:
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(primary, lineWidth: 3)
                        .scaleEffect(scale * (1 + CGFloat(i) * 0.3))
                        .opacity(1 - (scale - 0.5) * (1 + CGFloat(i) * 0.3))
                }
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
    let settings: AnimationSettings?
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Solid bright flash
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            (settings?.accentColor ?? .white).opacity(0.9),
                            (settings?.primaryColor ?? .cyan).opacity(0.8),
                            (settings?.secondaryColor ?? .blue).opacity(0.7),
                        ]),
                        startPoint: gradientStart,
                        endPoint: gradientEnd
                    )
                )

            // Glow effect
            Rectangle()
                .fill(settings?.primaryColor ?? .cyan)
                .blur(radius: 10)
                .opacity(0.6)
        }
        .scaleEffect(
            isVertical ? CGSize(width: 1.0, height: scale) : CGSize(width: scale, height: 1.0)
        )
        .onAppear {
            let duration = settings?.animationDuration ?? 0.6
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
