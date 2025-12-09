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
                .buttonStyle(.borderedProminent)
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

            Divider()
                .padding(.vertical)

            Text("Animation Preview")
                .font(.headline)

            AnimationView(shouldAnimate: $screenMonitor.shouldTriggerAnimation)
                .frame(width: 300, height: 200)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 550)
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
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Animation Settings"
        window.center()

        let hostingController = NSHostingController(
            rootView: SettingsView().environmentObject(animationSettings)
        )
        window.contentViewController = hostingController

        let controller = NSWindowController(window: window)
        settingsWindowController = controller

        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
