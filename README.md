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

### Android signing

Release builds are signed using credentials loaded from
`android/key.properties` (which is **not** checked in). The required
Gradle wiring lives in `android/app/signing-config.snippet.kts` —
paste those blocks into your generated `android/app/build.gradle.kts`.

To produce a signed release build:

1. Paste the signing blocks from
   `android/app/signing-config.snippet.kts` into
   `android/app/build.gradle.kts`.
2. Generate a keystore (once per app):
   ```bash
   keytool -genkey -v -keystore ~/tapbird-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias release
   ```
3. Copy the template and fill in your values:
   ```bash
   cp android/key.properties.example android/key.properties
   # edit android/key.properties:
   #   storePassword=...
   #   keyPassword=...
   #   keyAlias=release
   #   storeFile=/Users/you/tapbird-release.jks
   ```
4. Build:
   ```bash
   flutter build appbundle --release
   ```

If `key.properties` is absent, the release build falls back to the debug
keystore so the APK still installs on devices during development — but
Play Store uploads require a real release keystore.

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
<!-- REQUIRED: Flutter v2 embedding. Without this line Gradle fails
     with "use of deleted Android v1 embedding" on Flutter 3.x. -->
<meta-data
    android:name="flutterEmbedding"
    android:value="2" />

<!-- REQUIRED by google_mobile_ads. -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

A complete, minimal reference manifest is at
`android/app/src/main/AndroidManifest.xml.reference` — diff your manifest
against it if the build fails.

**MainActivity** — `android/app/src/main/kotlin/.../MainActivity.kt` must
extend `io.flutter.embedding.android.FlutterActivity`. If yours extends
`io.flutter.app.FlutterActivity` (note the `app.` vs `embedding.android.`
package), that's the removed v1 embedding — see
`android/app/src/main/kotlin/MainActivity.kt.reference`.

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

## App icon

The launcher icon is a chunky yellow bird on a sky-blue gradient, matching the
in-game art style. It is **generated from scratch** by
`tools/generate_icon.py` (pure Python + Pillow) — no third-party clipart,
fonts, or licensed assets are used, so it's free to ship.

Two PNGs live under `assets/icon/`:

| File                        | Purpose                                                         |
| --------------------------- | --------------------------------------------------------------- |
| `app_icon.png`              | 1024×1024 master icon (iOS + Android legacy)                    |
| `app_icon_foreground.png`   | 1024×1024 transparent foreground for Android adaptive icons     |

### The icon is already applied

All of the native icon files are checked into this repo, so you get the
bird launcher icon as soon as you `git pull` and rebuild — no extra steps,
no `dart run flutter_launcher_icons`. The committed tree includes:

- `android/app/src/main/res/mipmap-*/ic_launcher.png`,
  `ic_launcher_round.png`, `ic_launcher_foreground.png`
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (+ `_round`)
- `android/app/src/main/res/values/ic_launcher_background.xml`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` + `Contents.json`

To change the artwork, edit `tools/generate_icon.py` then run:

```bash
pip install Pillow
python3 tools/generate_icon.py
```

The script regenerates the master PNGs under `assets/icon/` **and**
overwrites every native icon file in-place.

### If the icon still looks unchanged

Run through this checklist in order — 99% of "icon didn't change" reports
hit one of these:

1. **The script printed `[skip]` lines.** That means `android/` or `ios/`
   don't exist yet in your local project. Run
   `flutter create --platforms=android,ios .` first, then re-run
   `python3 tools/generate_icon.py`.

2. **You only rebuilt with hot reload.** Icon resources aren't hot-reloaded:
   ```bash
   flutter clean
   flutter run
   ```

3. **Android is caching the old icon.** Android launchers cache icons
   aggressively. *Uninstall* the app from the device/emulator before
   running again. On Pixel devices, pull down on the home screen or
   reboot if the cache is still stuck.

4. **Verify the files were actually written.** After running the script,
   check a few paths:
   ```bash
   ls -la android/app/src/main/res/mipmap-xxxhdpi/
   # should show ic_launcher.png and ic_launcher_round.png,
   # each a few kilobytes (not the ~1KB default placeholder)

   ls -la ios/Runner/Assets.xcassets/AppIcon.appiconset/
   # should show 15+ Icon-App-*.png files
   ```

5. **iOS simulator caches icons too.** Device → Erase All Content and
   Settings, or at least delete the app and rerun `flutter run`.

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
