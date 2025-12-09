import AppKit
import SwiftUI

@main
struct ScreenTransitionAnimatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var screenMonitor = ScreenMonitor()
    var animationSettings = AnimationSettings()
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "arrow.left.arrow.right",
                accessibilityDescription: "Screen Transition Animator")
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Pass settings to monitor
        screenMonitor.animationSettings = animationSettings

        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 550)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: ContentView()
                .environmentObject(screenMonitor)
                .environmentObject(animationSettings)
        )

        // Auto-start monitoring
        screenMonitor.startMonitoring()
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            // Right-click: show settings
            showSettings()
        } else {
            // Left-click: toggle main popover
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showSettings() {
        print("showSettings called")

        if let window = settingsWindow {
            print("Reusing existing settings window")
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        print("Creating new settings window")
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Animation Settings"
        window.contentViewController = NSHostingController(
            rootView: SettingsView().environmentObject(animationSettings)
        )
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        print("Settings window created and shown")
        settingsWindow = window
    }
}
