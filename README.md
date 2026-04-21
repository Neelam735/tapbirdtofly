# Tap Bird to Fly

A Flappy Bird-style game built with Flutter. Runs on both **iOS** and **Android**
from a single Dart codebase, rendered entirely with `CustomPainter` (no external
game engine or image assets required).

## Gameplay

- Tap anywhere to flap and keep the bird airborne.
- Fly through the gaps between the pipes to score.
- Hitting a pipe, the ground, or the ceiling ends the run.
- Your best score is kept for the session.

## Prerequisites

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   (3.10 or newer).
2. For iOS: Xcode on macOS with a configured simulator or device.
3. For Android: Android Studio with an installed SDK/emulator, or a physical
   device with USB debugging enabled.

Verify your setup:

```bash
flutter doctor
```

## First-time setup

This repository ships with the pure-Dart source and `pubspec.yaml` only. Generate
the native iOS and Android project scaffolding with:

```bash
cd tapbirdtofly
flutter create --platforms=android,ios --org com.example .
flutter pub get
```

The command will not overwrite the existing `lib/` sources.

## Run the app

```bash
# Android emulator or device
flutter run -d android

# iOS simulator or device (from macOS)
flutter run -d ios
```

## Build release binaries

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (archive via Xcode afterwards)
flutter build ios --release
```

## Project layout

```
lib/
  main.dart                 # App entry, orientation + theme setup
  game/
    game_screen.dart        # Game loop (Ticker), input, state machine
    game_painter.dart       # CustomPainter for sky, clouds, pipes, bird, ground
    models.dart             # Bird, Pipe, GamePhase

test/
  widget_test.dart          # Smoke tests
```

## Tuning

Gameplay constants live at the top of `lib/game/game_screen.dart`:

| Constant       | Meaning                         |
| -------------- | ------------------------------- |
| `gravity`      | Downward acceleration (px/s²)   |
| `jumpVelocity` | Velocity set on each tap (px/s) |
| `pipeSpeed`    | Horizontal scroll speed (px/s)  |
| `pipeGap`      | Vertical gap size               |
| `pipeSpacing`  | Horizontal distance per pipe    |
| `birdRadius`   | Bird hitbox / sprite radius     |
