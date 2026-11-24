# Tasks

## 1. Configure the Runner scene manifest

- [x] 1.1 Add the documented single-window-scene configuration to `example/ios/Runner/Info.plist`, using `UIWindowScene`, `FlutterSceneDelegate`, the `flutter` configuration name, and the existing `Main` storyboard; verify the plist passes `plutil -lint` and contains the expected scene keys.

## 2. Verify iOS startup compatibility

- [x] 2.1 Run `flutter build ios --debug --no-codesign` from `example/` and verify the Runner app builds successfully.
- [x] 2.2 Run the example on an iOS 27 simulator with `flutter run --debug -d <iOS-27-simulator-udid> --no-resident`; verify it exits successfully, presents the Flutter app, and does not print the UIScene migration error.
- [x] 2.3 Run the example on an iOS 26 simulator with `flutter run --debug -d <iOS-26-simulator-udid> --no-resident`; verify scene-based startup remains functional on the earlier supported runtime.
