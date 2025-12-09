import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AnimationSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Animation Customization")
                    .font(.title2)
                    .fontWeight(.bold)

                // Colors Section
                GroupBox(label: Label("Colors", systemImage: "paintpalette.fill")) {
                    VStack(spacing: 12) {
                        ColorPickerRow(title: "Primary", color: $settings.primaryColor)
                        ColorPickerRow(title: "Secondary", color: $settings.secondaryColor)
                        ColorPickerRow(title: "Accent", color: $settings.accentColor)
                    }
                    .padding(.vertical, 8)
                }

                // Animation Style
                GroupBox(label: Label("Style", systemImage: "wand.and.stars")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Animation Style", selection: $settings.animationStyle) {
                            ForEach(AnimationSettings.AnimationStyle.allCases, id: \.self) {
                                style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)
                }

                // Options
                GroupBox(label: Label("Options", systemImage: "slider.horizontal.3")) {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Duration")
                                Spacer()
                                Text(String(format: "%.1fs", settings.animationDuration))
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.animationDuration, in: 0.2...1.5, step: 0.1)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Edge Thickness")
                                Spacer()
                                Text("\(Int(settings.flashThickness))px")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.flashThickness, in: 10...50, step: 5)
                        }

                        Toggle("Show Direction Arrow", isOn: $settings.showArrow)
                        Toggle("Show Particles", isOn: $settings.showParticles)
                    }
                    .padding(.vertical, 8)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: resetToDefaults) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Defaults")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: closeWindow) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Done")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text("Changes apply instantly")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(minWidth: 450, minHeight: 600)
    }

    private func resetToDefaults() {
        settings.primaryColor = .cyan
        settings.secondaryColor = .blue
        settings.accentColor = .white
        settings.animationStyle = .radialBurst
        settings.animationDuration = 0.6
        settings.flashThickness = 20
        settings.showArrow = true
        settings.showParticles = true
    }

    private func closeWindow() {
        if let window = NSApp.keyWindow {
            window.close()
        }
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: Color

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
            ColorPicker("", selection: $color, supportsOpacity: false)
                .labelsHidden()
            Spacer()
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
