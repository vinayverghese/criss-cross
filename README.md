# Screen Transition Animator

A native macOS app that triggers animations when your cursor moves between screens (e.g., MacBook display to external monitor).

## Features

- Real-time mouse position monitoring
- Automatic detection of screen transitions
- Customizable animations when switching screens
- Visual feedback with particle effects
- Transition counter
- System beep on transition

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

1. Launch the app
2. Click "Start Monitoring" to begin tracking cursor movement
3. Move your cursor between your MacBook screen and external monitor
4. Watch the animation trigger each time you cross screen boundaries

## Customization

You can customize the animation in `AnimationView.swift`:
- Change colors, shapes, and effects
- Adjust animation duration and timing
- Add more particle effects or transitions

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

## Notes

The app runs as a menu bar utility (LSUIElement = true in Info.plist), so it won't appear in the Dock.
