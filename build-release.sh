#!/bin/bash

# Build and Release Script for Screen Transition Animator

set -e  # Exit on error

echo "🔨 Building Screen Transition Animator..."

# Clean build folder
rm -rf build/

# Build the app
xcodebuild -project ScreenTransitionAnimator.xcodeproj \
  -scheme ScreenTransitionAnimator \
  -configuration Release \
  -derivedDataPath build/ \
  clean build

# Find the built app
APP_PATH=$(find build -name "ScreenTransitionAnimator.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
  echo "❌ Error: Could not find built app"
  exit 1
fi

echo "✅ App built successfully at: $APP_PATH"

# Create release directory
mkdir -p release
cp -R "$APP_PATH" release/

# Create ZIP
cd release
zip -r ScreenTransitionAnimator.app.zip ScreenTransitionAnimator.app
cd ..

echo "📦 Created release/ScreenTransitionAnimator.app.zip"
echo ""
echo "🚀 To create GitHub release, run:"
echo "   gh release create v1.0.0 release/ScreenTransitionAnimator.app.zip --title 'Screen Transition Animator v1.0.0' --notes-file RELEASE_NOTES.md"
