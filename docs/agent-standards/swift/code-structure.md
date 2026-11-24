# Swift code structure

Applies to all Swift code. Read together with `general/code-structure.md`. Where the two differ, this file wins.

## Idioms for the general rules
- **Early returns:** `guard` / `guard let` instead of nested `if let` pyramids.
- **Options type:** a `struct` once a function needs more than 3 parameters without default values. Argument labels don't make a long parameter list acceptable.
- **Singletons to avoid:** `.shared`, `.default`, `.standard`. Inject the dependency instead.
- **Global state to avoid:** `static var`. `static let` constants are fine.
- **Side effects to keep in the outer layer:** `Date()`, randomness, `UserDefaults`, `NotificationCenter`, `FileManager`, `URLSession`.

```swift
func importPrices(from file: URL) async throws -> ImportSummary {
  let rows = try parseCsv(file)
  let valid = validateRows(rows)
  try await savePrices(valid)
  return summarize(valid)
}
```

## Modules and access control
- A module's public surface is its `public` (or `package`) declarations; everything else stays `internal` or `private`.
- Mark declarations `private`/`fileprivate` by default and widen only when another file needs them.
- Never widen access just so another module or a test can reach it.
- In a single app target, feature folders are the boundary: other features use a feature's entry types, not its internal helpers.

## Layering
- Domain code imports only `Foundation`. Never `SwiftUI`, `UIKit`, `Combine`-bound UI code, persistence frameworks or networking code.
- **SwiftUI / UIKit:** views and view controllers only map state to UI and user intent to view model or service calls.
  - Business logic lives in services or the domain.
  - Persistence (Core Data, SwiftData, GRDB, etc.) lives in a per-feature repository/data-access type.
  - Views never talk to persistence or networking directly.

## Swift 6 concurrency
- Keep the project compiling under strict concurrency with no new warnings.
- UI-facing types are `@MainActor`.
- Use actors or value types for shared state instead of locks or `DispatchQueue`.
- Never add `@unchecked Sendable`, `nonisolated(unsafe)` or `@preconcurrency` (including `@preconcurrency import`) without a stated reason in a comment.

## Error handling
- Throw typed, meaningful errors (an `enum` conforming to `Error` per feature).
- No `try!`, force unwraps (`!`) or `fatalError` in production paths unless the invariant is guaranteed and stated in a comment.

## Before finishing
- Build and confirm no new compiler or concurrency warnings.
- Run SwiftLint and SwiftFormat if the project configures them.
