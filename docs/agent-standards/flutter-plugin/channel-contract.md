# Flutter plugin: platform channel contract

Applies to Flutter plugins. Read before changing anything that crosses the Dart ↔ Kotlin ↔ Swift boundary.

The channel boundary is one contract shared by three languages. Treat it like a public API.

## What the contract is
- Channel names.
- Method names.
- Argument keys and their types.
- Error codes.
- Event payload shapes (for `EventChannel`s).

## Where it is defined
- **With Pigeon:** the Pigeon definition file is the contract. Edit it and regenerate. Never hand-edit generated files.
- **Without Pigeon:** define the contract once per language as constants with identical values, and use no string literals for method names or keys anywhere else.

```dart
/// Names and keys shared with the Kotlin and Swift sides of the channel.
abstract final class ChannelContract {
  static const channel = 'com.example.ble/methods';
  static const connect = 'connect';
  static const argDeviceId = 'deviceId';
  static const errorNotConnected = 'not_connected';
  static const errorUnsupported = 'unsupported';
}
```

```kotlin
/** Names and keys shared with the Dart and Swift sides of the channel. */
internal object ChannelContract {
    const val CHANNEL = "com.example.ble/methods"
    const val CONNECT = "connect"
    const val ARG_DEVICE_ID = "deviceId"
    const val ERROR_NOT_CONNECTED = "not_connected"
    const val ERROR_UNSUPPORTED = "unsupported"
}
```

```swift
/// Names and keys shared with the Dart and Kotlin sides of the channel.
enum ChannelContract {
    static let channel = "com.example.ble/methods"
    static let connect = "connect"
    static let argDeviceId = "deviceId"
    static let errorNotConnected = "not_connected"
    static let errorUnsupported = "unsupported"
}
```

## Rules
- A contract change updates Dart, Kotlin and Swift in the same change. If the public Dart API changes, update `example/` too.
- Decode channel arguments into typed models at the boundary. Never pass raw maps (`Map<Object?, Object?>`, `Map<String, Any?>`, `[String: Any]`) past the entry layer.
- Both platforms implement the same semantics. If a platform can't support a method, return the `unsupported` error code. Never silently do nothing.
- Every method call gets exactly one reply: a success, an error or not-implemented.

## Before finishing
- If the contract changed, confirm that all three languages and the example app changed with it.
