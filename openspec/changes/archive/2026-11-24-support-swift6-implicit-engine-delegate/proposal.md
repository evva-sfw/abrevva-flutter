# Proposal

## Why

After migrating the example app to Flutter's UIScene lifecycle, its custom `AppDelegate` conforms to `FlutterImplicitEngineDelegate` so plugins can be registered when the implicit engine is initialized. The Swift 6 build now fails at that conformance because Flutter's Objective-C protocol does not express the actor isolation inherited by `FlutterAppDelegate`.

## What Changes

- Resolve the Swift 6 actor-isolation mismatch at the app-delegate protocol boundary without removing UIScene support or changing when generated plugins are registered.
- Keep the implicit-engine callback's plugin registration synchronous and preserve Flutter's documented registration path.
- Preserve `@main` on the example `AppDelegate` as the Runner target's Swift application entry point.
- Add validation for the example iOS build and document any remaining toolchain-specific constraint.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This is an app-integration compatibility fix with no intended channel or user-visible behavior change; specs are intentionally skipped.

## Impact

- `example/ios/Runner/AppDelegate.swift`, its Swift 6 conformance to Flutter's imported Objective-C delegate protocol, and the Runner target's Swift application entry point.
- The example iOS build and plugin registration path during implicit Flutter engine initialization.
