# Flutter plugin: entry layers

Applies to Flutter plugins. Adds plugin-specific rules on top of `dart/`, `kotlin/` and `swift/`. Read the section for the language you are editing.

In a plugin, the entry layer of each language is the thin outer layer from `general/code-structure.md`: it decodes, delegates and replies. It contains no business logic, persistence or networking.

## Dart (`lib/`)
- `lib/<plugin_name>.dart` is the only public API. Everything else is in `lib/src/` and not exported.
- Layering: public API → channel layer → services → domain.
- Only the channel layer (e.g. `MethodChannelBle`) imports `package:flutter/services.dart`.
  - It decodes replies into typed models.
  - It converts `PlatformException` into the plugin's own exception types.
  - Code above it never sees `PlatformException` or raw maps.
- **Federated plugins:** the settable `static instance` of the platform interface is allowed, because `plugin_platform_interface` requires it. It is the only exception to the no-static-state rule.

```dart
/// Calls the native side over the method channel and maps its errors.
/// The only class that imports `package:flutter/services.dart`.
class MethodChannelBle extends BlePlatform {
```

## Kotlin (`android/`)
- The class implementing `FlutterPlugin` / `MethodCallHandler` / `ActivityAware` only decodes `MethodCall`s, calls services and replies. It is public; everything else is `internal` or `private`.
- **Lifecycle:**
  - Create channels, services and the coroutine scope in `onAttachedToEngine`.
  - Clear handlers and cancel the scope in `onDetachedFromEngine`.
  - Hold an `Activity` only between `onAttachedToActivity` and `onDetachedFromActivity`, and handle the config-change variants.
  - Never store `Activity`, `Context` or `BinaryMessenger` in an `object` or `companion object`.
- **Coroutines:** the plugin owns one `CoroutineScope` (`SupervisorJob()` + main dispatcher) bound to the engine lifecycle.
- **Threading:** call `MethodChannel.Result` and `EventChannel.EventSink` on the main thread only.
- **`lateinit`:** allowed for fields set in `onAttachedToEngine` / `onAttachedToActivity`.
- **Errors:** map sealed errors to `result.error(code, message, details)` with a contract error code, in the entry class only.
- **Permissions:** check runtime permissions natively and report a missing permission as a typed error. Never crash or silently no-op.

## Swift (`ios/`)
- The `FlutterPlugin` class only decodes `FlutterMethodCall`s, calls services and encodes results.
- The plugin entry class is `@MainActor`.
- **Threading:** call `FlutterResult` and `FlutterEventSink` on the main thread only.
- **Concurrency:** `@preconcurrency import Flutter` needs a stated reason in a comment, like any other `@preconcurrency`.
- **Errors:** map typed errors to `FlutterError` with a contract error code, in the entry class only.
- **Native views:** if the plugin ships platform views, the SwiftUI/UIKit rules from `swift/code-structure.md` apply.

## Doc comments
`FlutterPlugin` lifecycle and handler methods (`onAttachedToEngine`, `onMethodCall`, `handle(_:result:)`, `register(with:)`) get full doc comments when they contain logic. Generated Pigeon output gets none.
