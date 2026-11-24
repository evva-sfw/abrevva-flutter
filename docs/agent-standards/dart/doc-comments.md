# Dart doc comments (dartdoc)

Applies to all Dart code. Read together with `general/doc-comments.md` for coverage tiers and the skip list.

All Dart documentation follows the [Effective Dart documentation guide](https://dart.dev/effective-dart/documentation), so dartdoc and the IDE pick it up.
- Use `///` line comments, not `/** */` blocks and not plain `//`.
- Refer to identifiers in scope with square brackets (`[device]`, `[BleDevice]`, `[stopScanning]`) so dartdoc links them and the `comment_references` lint checks them. Use backticks for literal values (`null`, `true`, `'scan'`).
- Start the summary with a third-person verb (`Connects …`, `Returns …`), not with "This method".

## Functions and methods
Dart has no callout tags, so parameters, return value and errors go into short prose paragraphs in a fixed order. Separate paragraphs with empty `///` lines:

1. **Summary:** one sentence. dartdoc uses the first paragraph as the summary.
2. **Discussion (optional, 1–2 lines):** side effects, isolate context, cancellation, ordering or a non-obvious constraint.
3. **Parameters:** mention **every** parameter as `[name]`, in declaration order, in the summary or in one paragraph. For callbacks, say when they are called and on which isolate.
4. **Returns:** a paragraph starting with `Returns` whenever the return type is not `void` or `Future<void>`. For a `Stream`, say what each event means and when the stream errors and closes.
5. **Throws:** a paragraph starting with `Throws`, naming every exception type the function throws (or completes its `Future` with) and when.

Correct:
```dart
/// Connects to a scanned [BleDevice] with an optional timeout.
///
/// [device] is the device to connect to. [onDisconnect] is called on the
/// main isolate when the connection drops. [timeout] limits how long to
/// wait; `null` waits indefinitely.
///
/// Returns `true` if the connection was established, `false` if the device
/// refused it.
Future<bool> connect(
  BleDevice device, {
  void Function()? onDisconnect,
  Duration? timeout,
}) async {
```

Correct (throwing, with discussion):
```dart
/// Reads the current value of a characteristic from the connected device.
///
/// Waits for any pending write on the same characteristic to finish first.
///
/// [characteristic] is the UUID of the characteristic to read.
///
/// Returns the raw characteristic value.
///
/// Throws a [BleNotConnectedException] if no device is connected and a
/// [BleTimeoutException] if the device does not answer.
Future<Uint8List> read(String characteristic) async {
```

Correct (stream, parameter mentioned in the summary):
```dart
/// Scans for nearby BLE peripherals that advertise [serviceUuid].
///
/// Returns a broadcast stream that emits each [BleDevice] once, the first
/// time it is seen. The stream closes when [stopScanning] is called and
/// emits a [BleException] if the scan fails.
Stream<BleDevice> scan(String serviceUuid) {
```

Correct (nothing to document beyond the summary, so discussion is required):
```dart
/// Stops the active scan.
///
/// Safe to call when no scan is running; results that arrive afterwards are
/// discarded.
void stopScanning() {
```

Wrong (block comment style, Swift-style callouts that dartdoc renders as a plain list):
```dart
/**
 * Connects to a device.
 * - parameter device: The device.
 * - returns: Success.
 */
```

Wrong (`onDisconnect` and `timeout` not mentioned, no `Returns` paragraph):
```dart
/// Connects to a scanned [BleDevice].
///
/// [device] is the device to connect to.
```

## Types with behavior and getters
2–3 lines. Getters describe their value in the summary (`/// Whether a device is currently connected.`), with no `Returns` paragraph.

```dart
/// Manages scanning for and connecting to BLE peripherals.
/// Must be used from the main isolate; holds at most one active connection at a time.
class BleManager {
```

## Abstract interfaces, data-only types, typedefs and constants
Exactly one `///` line.

```dart
/// Normalized price point used by every chart and export.
@immutable
class PricePoint { … }
```
