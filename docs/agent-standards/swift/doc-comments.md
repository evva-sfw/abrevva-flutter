# Swift doc comments (DocC)

Applies to all Swift code. Read together with `general/doc-comments.md` for coverage tiers and the skip list.

All Swift documentation uses Swift-DocC markup as described in Apple's [Writing symbol documentation in your source files](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files).
- Use `///` line comments, not `/** */` blocks and not plain `//`. Xcode Quick Help and DocC only pick up doc comments.
- Wrap type, parameter and value names in backticks.

## Functions and methods
Every function and method with logic gets a doc comment built from these parts, in this order:

1. **Summary:** one sentence. DocC uses the first paragraph as the summary, so keep it to that one sentence.
2. **Discussion (optional, 1–2 lines):** separated from the summary by an empty `///` line.
3. An empty `///` line.
4. **Callouts**, one per line, in this order:
   - `- parameter <name>:` for **every** parameter, in declaration order. `<name>` is the internal parameter name (`_ device: BleDevice` → `device`), not the argument label.
   - `- returns:` whenever the return type is not `Void`.
   - `- throws:` whenever the function `throws`. Name the error type or cases and when they are thrown.
5. A closing empty `///` line.

Formatting of the callout block:
- Write the keywords in lowercase: `- parameter`, `- returns:`, `- throws:`.
- Align all descriptions in one block to the same column.
- For closure parameters, say when the closure is called and on which actor/queue.

Correct:
```swift
/// This method connects to a scanned `BleDevice` with an optional timeout.
///
/// - parameter device:             Device of type `BleDevice`.
/// - parameter onDisconnect:       Optional disconnect callback closure.
/// - parameter timeout:            Optional connect timeout.
/// - returns:                      Success `Bool`.
///
public func connect(
    _ device: BleDevice,
    _ onDisconnect: DisconnectCallback? = nil,
    _ timeout: Int? = nil
) async -> Bool {
```

Correct (throwing, with discussion):
```swift
/// Reads the current value of a characteristic from the connected device.
///
/// Waits for any pending write on the same characteristic to finish first.
///
/// - parameter characteristic:     UUID of the characteristic to read.
/// - returns:                      Raw characteristic value as `Data`.
/// - throws:                       `BleError.notConnected` if no device is connected, `BleError.timeout` if the device does not answer.
///
public func read(_ characteristic: CBUUID) async throws -> Data {
```

Correct (no callouts, so discussion is required):
```swift
/// Stops the active scan.
///
/// Safe to call when no scan is running; results that arrive afterwards are discarded.
///
public func stopScanning() {
```

Wrong (block comment style):
```swift
/**
 * Connects to a scanned device.
 * Returns true on success.
 */
```

Wrong (parameter missing, argument label instead of internal name, no `- returns:`):
```swift
/// This method connects to a scanned `BleDevice` with an optional timeout.
///
/// - parameter _:                  Device of type `BleDevice`.
/// - parameter timeout:            Optional connect timeout.
///
```

## Types with behavior and computed properties
2–3 lines. No callouts. Computed properties describe their value in the summary instead of using `- returns:`.

```swift
/// Manages scanning for and connecting to BLE peripherals.
/// Isolated to its own actor; holds at most one active connection at a time.
public actor BleManager {
```

## Protocols, data-only types, type aliases and constants
Exactly one `///` line.

```swift
/// Normalized price point used by every chart and export.
struct PricePoint: Sendable, Equatable { … }
```
