# Yoga Guru

A modern, offline yoga instructor app built with Flutter. Yoga Guru was rebuilt from the
original 2019 project so it runs on current Flutter and Dart versions with a polished
Material 3 interface, a guided pose library, timed practice sessions and local progress
tracking.

> Originally based on [adityaas26/Yoga-Guru](https://github.com/adityaas26/Yoga-Guru).
> The Firebase login, camera and TensorFlow Lite pose-detection code has been removed
> (see [What changed](#what-changed)) and replaced with a reliable, fully working
> offline experience.

## Features

- **Home** – greeting, today's practice card, featured sessions, beginner/intermediate/
  advanced levels and popular poses.
- **Pose library (Explore)** – 14 yoga poses with images, search and difficulty filters.
- **Pose details** – description, step-by-step instructions, benefits, suggested duration
  and safety notes.
- **Camera form check (Android)** – on-device pose detection with Google ML Kit: a live
  skeleton overlay and geometry-based form scoring for Mountain Pose, Tree Pose and
  Warrior II (score, per-cue feedback and a good-form hold timer). Other poses show the
  live skeleton as a mirror guide. Works fully offline; no account or API key.
- **Guided sessions** – countdown timer with start / pause / resume / reset / skip,
  current pose cue, next-pose preview and a completion summary screen.
- **Progress** – completed sessions, total practice time, current streak, daily goal ring,
  a last-7-days chart and recent session history. All data is stored locally.
- **Profile & settings** – display name, light/dark/system theme, daily goal and a
  reset-progress option.
- **Bottom navigation** – Home, Explore, Progress, Profile, with per-tab state preserved.

Everything works offline. No account, backend, API key or network access is required.
The camera form check runs entirely on the device with Google ML Kit and is available on
Android only (the button is hidden on other platforms).

## Requirements

| Tool | Version used and tested |
| --- | --- |
| Flutter | 3.47.7 (stable) |
| Dart | 3.13.5 |
| JDK | 17+ (Java 25 tested) |
| Android SDK | Platform 36, Build-Tools 36.0.0 |
| Android device | Android 7.0 (API 24) or newer |

Dependencies: `shared_preferences` (local storage), `camera` + `google_mlkit_pose_detection`
(camera form check), `cupertino_icons`. Lints: `flutter_lints`.

## Quick start

```sh
# from the repository root
flutter pub get
flutter analyze
flutter test
flutter run          # with an Android phone connected (USB debugging on)
```

## Run on a physical Android phone (USB debugging)

1. On the phone, open **Settings → About phone** and tap **Build number** 7 times to
   enable Developer options.
2. Open **Settings → Developer options** and enable **USB debugging**.
3. Connect the phone with a USB cable and accept the "Allow USB debugging" prompt on
   the phone.
4. Verify the device is detected:

   ```sh
   flutter devices
   ```

5. Run the app (release build is recommended for smooth performance on a phone):

   ```sh
   flutter run --release
   ```

   Use plain `flutter run` only if you need hot reload during development.

## Build an installable APK

```sh
flutter build apk --debug     # debug build
flutter build apk --release   # release build (signed with debug keys)
```

Output path:

```
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/flutter-apk/app-debug.apk
```

### Install the APK on the phone

Option A – with the phone connected over USB:

```sh
flutter install --release
```

Option B – copy the file manually:

1. Transfer `app-release.apk` to the phone (USB cable, Google Drive, etc.).
2. On the phone, open the APK from **Files** and allow **Install unknown apps**
   for your file manager when prompted.
3. Tap **Install**.

## Project structure

```
lib/
  main.dart                     # entry point
  app.dart                      # MaterialApp + app scope wiring
  data/                         # pose library and curated session plans
  models/                       # YogaPose, YogaSession, SessionRecord
  screens/                      # home, explore, detail, session, progress, profile, settings
  services/                     # local storage, app state, inherited scope
  theme/                        # Material 3 theme (sage green / cream / charcoal)
  utils/                        # formatters and page transitions
  widgets/                      # reusable cards, tiles, empty states, progress ring
assets/
  poses/                        # 14 pose illustrations (bundled, offline)
  images/                       # app imagery
test/                           # unit and widget tests
```

## What changed

- SDK constraint updated from `>=2.2.2 <3.0.0` to `^3.13.5`; the whole app is null-safe.
- Removed unmaintained/obsolete dependencies: `firebase_auth`, `cloud_firestore`,
  `firebase_storage`, `tflite`, `percent_indicator`, `flutter_swiper`, `image_picker`.
- Removed the Firebase login/register flow (it required a private backend project and
  `google-services.json`). The profile is now local to the device — no fake login.
- The original TensorFlow Lite / PoseNet pipeline used the removed Flutter v1 Android
  embedding and an abandoned `tflite` package, so it could not be kept as-is. It has been
  replaced with a maintained **Google ML Kit** pose detector (`google_mlkit_pose_detection`,
  on-device, offline) plus geometry-based form scoring for three poses. No AI feature is
  claimed to work unless it is implemented.
- Android files regenerated with the current Flutter template: Gradle 9.3.1,
  Android Gradle Plugin 9.1.0, Kotlin 2.4.0, `compileSdk`/`targetSdk` 36, `minSdk` 24.
- Progress, profile and settings persist through `shared_preferences`, with corrupt
  stored data handled gracefully.

## Troubleshooting

- `flutter pub get` fails: run `flutter --version` and confirm Flutter 3.47+/Dart 3.13+.
- First Android build is slow: Gradle and Android dependencies are downloaded once.
- `sdkmanager` license errors: run
  `sdkmanager --licenses` (SDK cmdline-tools) and accept all licenses.
- Gradle error mentioning `llvm-strip` / `llvm-objcopy` / missing NDK: the release
  build strips the pre-built Flutter engine libraries with the NDK's LLVM tools.
  Either install the NDK (`sdkmanager --install "ndk;28.2.13676358"`, a large
  download), or make sure the NDK LLVM tools are available under
  `<Android SDK>/ndk/28.2.13676358/toolchains/llvm/prebuilt/windows-x86_64/bin/`.
- Phone not detected: check the USB cable, `adb devices`, and the USB debugging prompt.
- Uninstall/reset data: clearing app data resets the profile, progress and settings.
