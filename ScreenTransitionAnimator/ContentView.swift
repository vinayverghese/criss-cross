import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenMonitor: ScreenMonitor
    @EnvironmentObject var animationSettings: AnimationSettings

    var body: some View {
        VStack(spacing: 20) {
            Text("Screen Transition Animator")
                .font(.title)
                .fontWeight(.bold)

            Text("Current Screen: \(screenMonitor.currentScreenName)")
                .font(.headline)

            Text("Transitions: \(screenMonitor.transitionCount)")
                .font(.subheadline)

            if screenMonitor.isMonitoring {
                Text("Monitoring Active")
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }

            VStack(spacing: 12) {
                Text("Flash Animation Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("Flash Type", selection: $screenMonitor.flashType) {
                    ForEach(ScreenMonitor.FlashType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(screenMonitor.isMonitoring)
            }
            .padding(.vertical, 8)

            VStack(spacing: 8) {
                Button(screenMonitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                    if screenMonitor.isMonitoring {
                        screenMonitor.stopMonitoring()
                    } else {
                        screenMonitor.startMonitoring()
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                HStack(spacing: 8) {
                    Button("Customize...") {
                        openSettings()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)

                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 280)
    }

    @State private var settingsWindowController: NSWindowController?

    private func openSettings() {
        // Reuse existing window if available
        if let controller = settingsWindowController, let window = controller.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 650),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Animation Settings"
        window.minSize = NSSize(width: 450, height: 600)
        window.center()

        let hostingController = NSHostingController(
            rootView: SettingsView().environmentObject(animationSettings)
        )
        window.contentViewController = hostingController
        hostingController.view.frame = window.contentView?.bounds ?? .zero

        let controller = NSWindowController(window: window)
        settingsWindowController = controller

        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
