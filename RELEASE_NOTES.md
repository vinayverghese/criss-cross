# Screen Transition Animator v1.0.0

## 🎉 Initial Release

A native macOS menu bar app that triggers beautiful animations when your cursor moves between screens.

### ✨ Features

- **Smart Detection** - Automatically detects when you move between displays
- **Three Animation Modes**
  - At Cursor - Flash appears where you cross the boundary
  - Screen Edge - Flash on the edge you enter
  - Both - Combined effect
- **Full Customization**
  - Choose your own colors (primary, secondary, accent)
  - 4 animation styles (Radial Burst, Linear Wave, Pulse, Ripple)
  - Adjustable duration (0.2s - 1.5s)
  - Adjustable edge thickness (10px - 50px)
  - Toggle direction arrows and particles
- **Settings Persistence** - Your customizations are saved automatically
- **Menu Bar App** - Unobtrusive, always accessible
- **Fast & Efficient** - 20ms polling for smooth detection

### 📦 Installation

1. Download `ScreenTransitionAnimator.app.zip` from the Assets below
2. Unzip the file
3. Drag `ScreenTransitionAnimator.app` to your Applications folder
4. Launch the app
5. Click the menu bar icon (⟷) to access controls
6. Click "Customize..." to personalize your animations

### 🔧 Building from Source

```bash
git clone https://github.com/YOUR_USERNAME/cursor-animation.git
cd cursor-animation
open ScreenTransitionAnimator.xcodeproj
# Build and run in Xcode (⌘R)
```

### 📋 Requirements

- macOS 13.0 or later
- Multiple displays (MacBook + external monitor, etc.)

### 🐛 Known Issues

None! This is a stable initial release.

### 🙏 Feedback

Found a bug or have a feature request? Please [open an issue](https://github.com/YOUR_USERNAME/cursor-animation/issues)!

---

**Note:** The app is not notarized yet. On first launch, you may need to:
1. Right-click the app
2. Select "Open"
3. Click "Open" in the dialog

This only needs to be done once.
