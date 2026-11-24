# Kotlin doc comments (KDoc)

Applies to all Kotlin code. Read together with `general/doc-comments.md` for coverage tiers and the skip list.

All Kotlin documentation uses [KDoc](https://kotlinlang.org/docs/kotlin-doc.html), so Dokka and Android Studio Quick Documentation pick it up.
- Use `/** */` KDoc blocks. Never use `//` or `///` for documentation.
- Refer to declarations with square brackets (`[BleDevice]`, `[connect]`) so Dokka links them. Use backticks for literal values (`null`, `true`, `"scan"`).

## Functions and methods
Every function and method with logic gets a KDoc block built from these parts, in this order:

1. **Summary:** one sentence.
2. **Discussion (optional, 1–2 lines):** separated by an empty ` *` line. Use it for side effects, dispatcher/thread context, cancellation behavior of a `suspend` function or a non-obvious constraint.
3. An empty ` *` line.
4. **Tags**, one per line, in this order:
   - `@param <name>` for **every** parameter, in declaration order.
   - `@return` whenever the return type is not `Unit`.
   - `@throws <ExceptionType>` for every exception the function throws or deliberately lets propagate, one tag per type. Kotlin has no checked exceptions, so this is the only place callers learn about them.

Formatting of the tag block:
- Write the tags in lowercase: `@param`, `@return`, `@throws`.
- Align all descriptions in one block to the same column.
- For lambda parameters, say when the lambda is called and on which thread or dispatcher.

Correct:
```kotlin
/**
 * Connects to a scanned [BleDevice] with an optional timeout.
 *
 * @param device                    Device to connect to.
 * @param onDisconnect              Called on the main thread when the connection drops, or `null`.
 * @param timeoutMs                 Connect timeout in milliseconds, or `null` to wait indefinitely.
 * @return                          `true` if the connection was established, `false` if the device refused it.
 */
suspend fun connect(
    device: BleDevice,
    onDisconnect: (() -> Unit)? = null,
    timeoutMs: Long? = null,
): Boolean {
```

Correct (throwing, with discussion):
```kotlin
/**
 * Reads the current value of a characteristic from the connected device.
 *
 * Suspends until any pending write on the same characteristic has finished.
 *
 * @param characteristic            UUID of the characteristic to read.
 * @return                          Raw characteristic value.
 * @throws BleException.NotConnected If no device is connected.
 * @throws BleException.Timeout     If the device does not answer.
 */
suspend fun read(characteristic: UUID): ByteArray {
```

Correct (no tags, so discussion is required):
```kotlin
/**
 * Stops the active scan.
 *
 * Safe to call when no scan is running; results that arrive afterwards are discarded.
 */
fun stopScanning() {
```

Wrong (plain `//` comments, which KDoc ignores):
```kotlin
// Connects to a scanned device.
// Returns true on success.
suspend fun connect(device: BleDevice, timeoutMs: Long? = null): Boolean {
```

Wrong (parameter missing, no `@return`, Swift-style callouts):
```kotlin
/**
 * Connects to a scanned [BleDevice] with an optional timeout.
 *
 * - parameter timeoutMs: Optional connect timeout.
 */
```

## Types with behavior and computed properties
2–3 lines. No tags. Properties with a custom getter describe their value in the summary instead of using `@return`.

```kotlin
/**
 * Manages scanning for and connecting to BLE peripherals.
 * Owns a coroutine scope that its owner cancels; holds at most one active connection at a time.
 */
internal class BleManager(
```

## Interfaces, data-only types, type aliases and constants
Exactly one line, as a single-line KDoc block.

```kotlin
/** Normalized price point used by every chart and export. */
internal data class PricePoint(val timestamp: Long, val price: Double)
```
