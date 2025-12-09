import Cocoa
import SwiftUI

class ScreenMonitor: ObservableObject {
    @Published var currentScreenName: String = "Unknown"
    @Published var transitionCount: Int = 0
    @Published var isMonitoring: Bool = false
    @Published var shouldTriggerAnimation: Bool = false
    @Published var flashType: FlashType = .cursor

    private var eventMonitor: Any?
    private var currentScreen: NSScreen?
    private var timer: Timer?
    private var flashWindow: FlashOverlayWindow?
    private var lastMousePosition: NSPoint = .zero

    enum FlashType: String, CaseIterable {
        case cursor = "At Cursor"
        case edge = "Screen Edge"
        case both = "Both"
    }

    func startMonitoring() {
        isMonitoring = true
        currentScreen = NSScreen.main
        updateScreenName()
        lastMousePosition = NSEvent.mouseLocation

        // Monitor mouse movement using a timer (faster polling for quick movements)
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            self?.checkMousePosition()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }

    private func checkMousePosition() {
        let mouseLocation = NSEvent.mouseLocation

        // Find which screen contains the mouse
        if let screen = NSScreen.screens.first(where: { screen in
            NSMouseInRect(mouseLocation, screen.frame, false)
        }) {
            // Check if we've moved to a different screen
            if let current = currentScreen, screen != current {
                // Calculate boundary position between screens for more accurate flash
                let boundaryPosition = calculateBoundaryPosition(
                    from: current, to: screen, lastPos: lastMousePosition, currentPos: mouseLocation
                )
                handleScreenTransition(from: current, to: screen, mousePosition: boundaryPosition)
            }
            currentScreen = screen
        }

        lastMousePosition = mouseLocation
    }

    private func calculateBoundaryPosition(
        from oldScreen: NSScreen, to newScreen: NSScreen, lastPos: NSPoint, currentPos: NSPoint
    ) -> NSPoint {
        let oldFrame = oldScreen.frame
        let newFrame = newScreen.frame

        // Determine if transition is primarily horizontal or vertical
        let oldCenterX = oldFrame.midX
        let newCenterX = newFrame.midX
        let deltaX = abs(newCenterX - oldCenterX)
        let deltaY = abs(newFrame.midY - oldFrame.midY)

        if deltaX > deltaY {
            // Horizontal transition - find the X boundary
            let boundaryX: CGFloat
            if newCenterX < oldCenterX {
                // Moving left - use the left edge of old screen or right edge of new screen
                boundaryX = max(newFrame.maxX, oldFrame.minX)
            } else {
                // Moving right - use the right edge of old screen or left edge of new screen
                boundaryX = min(oldFrame.maxX, newFrame.minX)
            }
            // Keep the Y position from current mouse
            return NSPoint(x: boundaryX, y: currentPos.y)
        } else {
            // Vertical transition - find the Y boundary
            let boundaryY: CGFloat
            if newFrame.midY < oldFrame.midY {
                // Moving down
                boundaryY = max(newFrame.maxY, oldFrame.minY)
            } else {
                // Moving up
                boundaryY = min(oldFrame.maxY, newFrame.minY)
            }
            // Keep the X position from current mouse
            return NSPoint(x: currentPos.x, y: boundaryY)
        }
    }

    private func handleScreenTransition(
        from oldScreen: NSScreen, to newScreen: NSScreen, mousePosition: NSPoint
    ) {
        DispatchQueue.main.async {
            self.transitionCount += 1
            self.updateScreenName()
            self.triggerAnimation()

            // Determine transition direction
            let direction = self.getTransitionDirection(
                from: oldScreen, to: newScreen, mousePosition: mousePosition)

            let edge = self.getScreenEdge(from: oldScreen, to: newScreen)

            // Show flash animation - create fresh windows each time
            switch self.flashType {
            case .cursor:
                let cursorWindow = FlashOverlayWindow()
                cursorWindow.showFlash(at: mousePosition, direction: direction)
            case .edge:
                if let edge = edge {
                    let edgeWindow = FlashOverlayWindow()
                    edgeWindow.showEdgeFlash(edge: edge, screen: newScreen)
                }
            case .both:
                let cursorWindow = FlashOverlayWindow()
                cursorWindow.showFlash(at: mousePosition, direction: direction)
                if let edge = edge {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        let edgeWindow = FlashOverlayWindow()
                        edgeWindow.showEdgeFlash(edge: edge, screen: newScreen)
                    }
                }
            }

        }
    }

    private func getTransitionDirection(
        from oldScreen: NSScreen, to newScreen: NSScreen, mousePosition: NSPoint
    ) -> TransitionDirection {
        let oldFrame = oldScreen.frame
        let newFrame = newScreen.frame

        // Calculate the center points to determine relative position
        let oldCenterX = oldFrame.midX
        let newCenterX = newFrame.midX
        let oldCenterY = oldFrame.midY
        let newCenterY = newFrame.midY

        // Determine primary direction based on center positions
        let deltaX = abs(newCenterX - oldCenterX)
        let deltaY = abs(newCenterY - oldCenterY)

        if deltaX > deltaY {
            // Horizontal transition
            if newCenterX < oldCenterX {
                return .left
            } else {
                return .right
            }
        } else {
            // Vertical transition
            if newCenterY < oldCenterY {
                return .down
            } else {
                return .up
            }
        }
    }

    private func getScreenEdge(from oldScreen: NSScreen, to newScreen: NSScreen) -> NSRectEdge? {
        let oldFrame = oldScreen.frame
        let newFrame = newScreen.frame

        // Calculate the center points to determine relative position
        let oldCenterX = oldFrame.midX
        let newCenterX = newFrame.midX
        let oldCenterY = oldFrame.midY
        let newCenterY = newFrame.midY

        // Determine primary direction based on center positions
        let deltaX = abs(newCenterX - oldCenterX)
        let deltaY = abs(newCenterY - oldCenterY)

        if deltaX > deltaY {
            // Horizontal transition
            if newCenterX < oldCenterX {
                // New screen is to the LEFT, so we enter from its RIGHT edge
                return .maxX
            } else {
                // New screen is to the RIGHT, so we enter from its LEFT edge
                return .minX
            }
        } else {
            // Vertical transition
            if newCenterY < oldCenterY {
                // New screen is BELOW, so we enter from its TOP edge
                return .maxY
            } else {
                // New screen is ABOVE, so we enter from its BOTTOM edge
                return .minY
            }
        }
    }

    private func updateScreenName() {
        guard let screen = currentScreen else {
            currentScreenName = "Unknown"
            return
        }

        if screen == NSScreen.main {
            currentScreenName = "Main Display"
        } else if let index = NSScreen.screens.firstIndex(of: screen) {
            currentScreenName = "Display \(index + 1)"
        } else {
            currentScreenName = "External Display"
        }
    }

    private func triggerAnimation() {
        shouldTriggerAnimation = true

        // Reset after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.shouldTriggerAnimation = false
        }
    }

    deinit {
        stopMonitoring()
    }
}
