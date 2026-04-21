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
  main.dart                         # App entry, orientation + AdMob init
  game/
    game_screen.dart                # Game loop (Ticker), input, state machine
    game_painter.dart               # CustomPainter for sky, clouds, pipes, bird, ground
    models.dart                     # Bird, Pipe, GamePhase
  ads/
    ad_helper.dart                  # Banner + interstitial unit IDs (test/prod toggle)
    banner_ad_widget.dart           # Adaptive banner anchored at the bottom
    interstitial_ad_controller.dart # Throttled interstitial (every Nth game over)

test/
  widget_test.dart                  # Smoke tests
```

## Ads (AdMob via `google_mobile_ads`)

### Placement strategy

| Ad type          | Location                              | Trigger                | Rationale                                            |
| ---------------- | ------------------------------------- | ---------------------- | ---------------------------------------------------- |
| Banner           | Bottom strip, below the play field    | Always visible         | Persistent revenue, tap area is isolated above it    |
| Interstitial     | Full-screen on Game Over              | Every 3rd death        | Natural pause, throttled so retention isn't damaged  |
| Rewarded (TODO)  | Opt-in "Continue" button on Game Over | Player taps to revive  | Highest eCPM, player-friendly (not yet implemented)  |

**Intentionally avoided**: banners inside the play area (misclicks, policy
risk), interstitials after every death (kills retention), any ad during
active gameplay.

### Required native configuration

`flutter create` will not add AdMob-specific native config. After running
`flutter create`, edit the generated files:

**Android** — `android/app/src/main/AndroidManifest.xml`, inside
`<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

(That is Google's sample app ID; swap it for your real AdMob app ID before
release.)

`android/app/build.gradle` — ensure `minSdkVersion >= 23`.

**iOS** — `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads.</string>
```

(See the [AdMob Flutter quick start](https://developers.google.com/admob/flutter/quick-start)
for the full `SKAdNetworkItems` list.)

### Going from test → production

1. Open `lib/ads/ad_helper.dart`.
2. Replace each `_prod*` constant with the unit IDs from your AdMob console.
3. Set `useTestAds = false`.
4. Replace the Android `APPLICATION_ID` meta-data and iOS
   `GADApplicationIdentifier` with your real AdMob app IDs.

### Tuning ad frequency

`lib/game/game_screen.dart`:

```dart
InterstitialAdController(showEvery: 3) // show one interstitial per N game overs
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
