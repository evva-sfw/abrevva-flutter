# Proposal

## Why

The example app still fails to launch on iOS 27 because Flutter detects that its `Info.plist` has not adopted the UIScene lifecycle. Its customized `AppDelegate` prevents Flutter's automatic migration, and the plist currently has no `UIApplicationSceneManifest`.

## What Changes

- Configure the example Runner target for one `UIWindowScene` using Flutter's `FlutterSceneDelegate` and the existing `Main` storyboard.
- Preserve the `@main` AppDelegate and synchronous implicit-engine plugin registration already required by the customized Flutter app delegate.
- Validate launch on an iOS 27 simulator and confirm Flutter's UIScene migration error is absent.

## Capabilities

### New Capabilities

- `example-ios-lifecycle`: The example iOS app starts through Flutter's supported single-scene UIKit lifecycle.

### Modified Capabilities

None.

## Impact

- `example/ios/Runner/Info.plist` and the existing example `AppDelegate`/storyboard configuration.
- iOS 27 example-app startup. No plugin channel contract, plugin implementation, Flutter SDK, or separate SDK repository changes are intended.
