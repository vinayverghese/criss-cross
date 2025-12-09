import Cocoa
import SwiftUI

class FlashOverlayWindow: NSWindow {
    init() {
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
        let hostingView = NSHostingView(rootView: FlashAnimationView(direction: direction))
        self.contentView = hostingView

        // Position window at cursor
        let size = CGSize(width: 200, height: 200)
        let origin = CGPoint(x: position.x - size.width / 2, y: position.y - size.height / 2)
        self.setFrame(NSRect(origin: origin, size: size), display: true)

        self.orderFrontRegardless()
        self.alphaValue = 1.0

        // Fade out and close
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.8
                self.animator().alphaValue = 0.0
            },
            completionHandler: {
                self.orderOut(nil)
            })
    }

    func showEdgeFlash(edge: NSRectEdge, screen: NSScreen) {
        let hostingView = NSHostingView(rootView: EdgeFlashView(edge: edge))
        self.contentView = hostingView

        let screenFrame = screen.frame
        var flashFrame: NSRect
        let thickness: CGFloat = 20  // Increased thickness for visibility

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

        // Fade out
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.6
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
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Radial gradient flash
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.cyan.opacity(0.6),
                    Color.blue.opacity(0.3),
                    Color.clear,
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 100
            )
            .scaleEffect(scale)

            // Directional arrow
            Image(systemName: arrowIcon)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .cyan, radius: 10)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                scale = 2.0
            }
            withAnimation(.easeOut(duration: 0.3)) {
                rotation = 360
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
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Solid bright flash
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.cyan.opacity(0.8),
                            Color.blue.opacity(0.7),
                        ]),
                        startPoint: gradientStart,
                        endPoint: gradientEnd
                    )
                )

            // Glow effect
            Rectangle()
                .fill(Color.cyan)
                .blur(radius: 10)
                .opacity(0.6)
        }
        .scaleEffect(
            isVertical ? CGSize(width: 1.0, height: scale) : CGSize(width: scale, height: 1.0)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
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
