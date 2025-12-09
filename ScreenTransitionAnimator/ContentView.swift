import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenMonitor: ScreenMonitor

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

            HStack(spacing: 12) {
                Button(screenMonitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                    if screenMonitor.isMonitoring {
                        screenMonitor.stopMonitoring()
                    } else {
                        screenMonitor.startMonitoring()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
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
}
