# Design

## Context

See `proposal.md` for the motivation and `specs/example-ios-lifecycle/spec.md` for the behavior contract. `Runner/Info.plist` currently has a `Main` storyboard but no `UIApplicationSceneManifest`. The customized `AppDelegate` already has `@main` and registers generated plugins synchronously from `didInitializeImplicitFlutterEngine`; the Runner target contains no custom `SceneDelegate` source file.

## Goals / Non-Goals

**Goals:**
- Declare one application `UIWindowScene` and connect it to the existing `Main` storyboard.
- Use Flutter's scene delegate so Flutter receives scene lifecycle callbacks.
- Keep the existing Swift 6-compatible `AppDelegate` and implicit-engine registration unchanged.

**Non-Goals:**
- Add multiple-scene support, which Flutter does not fully support.
- Create a custom `SceneDelegate` subclass when the example has no custom scene behavior to host.
- Change plugin code, channel contracts, the Flutter SDK, or the separate iOS SDK repository.

## Decisions

1. **Configure the scene in `Runner/Info.plist`.** Add `UIApplicationSceneManifest`, set `UIApplicationSupportsMultipleScenes` to `false`, and provide the `UIWindowSceneSessionRoleApplication` configuration using `UIWindowScene`, `FlutterSceneDelegate`, configuration name `flutter`, and storyboard `Main`. This matches Flutter's manual migration guidance and built-in migration output.

2. **Use Flutter's built-in scene delegate directly.** Do not add a custom Swift `SceneDelegate.swift`; Flutter documents a subclass as optional, needed only when the app requires custom scene handling. The example has no such handling, so the built-in class is the smaller, lower-risk integration.

3. **Keep app and engine responsibilities separate.** Retain `@main` and the existing `FlutterImplicitEngineDelegate` callback in `AppDelegate`. Do not move plugin registration back to `didFinishLaunchingWithOptions` or alter channel behavior; the scene manifest addresses scene startup while the callback handles implicit-engine plugin registration.

4. **Use an iOS 27 simulator launch as the regression signal.** Run the example on an available iOS 27 simulator and verify that `flutter run` exits successfully, the UIScene-required message is absent, and the Flutter interface launches. Also build the example for iOS to catch plist or native build errors.

## Risks / Trade-offs

- [A typo or invalid plist structure can leave the app without a usable scene configuration] → Validate `Info.plist` with `plutil -lint` and launch on iOS 27.
- [A Flutter SDK update may change migration expectations] → Follow the migration guidance and template shipped with the project's configured Flutter SDK; keep the runtime launch check as the acceptance signal.
- [The iOS 27 simulator may expose additional startup issues after the migration guard is removed] → Treat those as separate failures; capture the exact output instead of weakening or disabling UIScene support.

## Migration Plan

1. Add the single-scene manifest to `example/ios/Runner/Info.plist`, pointing to `FlutterSceneDelegate` and `Main`.
2. Validate the plist and build the example iOS app.
3. Launch on an iOS 27 simulator and confirm the specific migration error is absent and the Flutter UI appears.
4. If the scene fails to initialize, capture the new UIKit/Flutter error and reassess the scene configuration before adding custom lifecycle code.
