# Screen Transition Animator

A native macOS app that triggers animations when your cursor moves between screens (e.g., MacBook display to external monitor).

## Features

- **Menu bar app** - Unobtrusive, always accessible
- **Real-time monitoring** - Fast cursor tracking (20ms polling)
- **Multiple animation modes**:
  - At Cursor - Flash appears where you cross
  - Screen Edge - Flash on the edge you enter
  - Both - Combined effect
- **Fully customizable**:
  - Choose your own colors (primary, secondary, accent)
  - 4 animation styles (Radial Burst, Linear Wave, Pulse, Ripple)
  - Adjustable duration and thickness
  - Toggle arrows and particles
- **Smart detection** - Works with overlapping screens
- **Silent operation** - No sounds

## How It Works

The app uses a timer-based polling approach to monitor mouse position every 100ms. When it detects the cursor has moved to a different screen, it:

1. Triggers a visual animation
2. Plays a system beep
3. Updates the transition counter
4. Shows which screen you're currently on

## Building & Running

1. Open `ScreenTransitionAnimator.xcodeproj` in Xcode
2. Select your development team in the project settings (Signing & Capabilities)
3. Build and run (⌘R)

## Usage

1. Launch the app - it appears in the menu bar (⟷ icon)
2. Monitoring starts automatically
3. Move your cursor between screens to see animations
4. **Left-click** menu bar icon - View stats and controls
5. **Right-click** menu bar icon - Open customization settings

## Customization

Right-click the menu bar icon to access settings:

- **Colors**: Pick custom colors for primary, secondary, and accent
- **Animation Style**: Choose from 4 different styles
- **Duration**: Adjust animation speed (0.2s - 1.5s)
- **Edge Thickness**: Control flash width (10px - 50px)
- **Options**: Toggle direction arrows and particle effects
- **Reset**: Restore default settings anytime

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.0 or laterHi

## Notes

The app runs as a menu bar utility (LSUIElement = true in Info.plist), so it won't appear in the Dock.
