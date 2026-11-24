# Dart code structure

Applies to all Dart code. Read together with `general/code-structure.md`. Where the two differ, this file wins.

## Idioms for the general rules
- **Early returns:** `if (x == null) return;` and rely on type promotion. Use `switch` expressions and patterns instead of `if`/`else` ladders.
- **Options type:** an immutable class once a function needs more than 3 parameters without default values. `required` named parameters count toward the limit.
- **Singletons to avoid:** `Foo.instance`, top-level service variables. Inject the dependency instead.
- **Global state to avoid:** top-level non-`final` variables and non-`final` `static` fields. `const` and `final` constants are fine.
- **Side effects to keep in the outer layer:** `DateTime.now()`, `Random()`, `dart:io`, `SharedPreferences`, `MethodChannel`, HTTP clients.

```dart
Future<ImportSummary> importPrices(File file) async {
  final rows = parseCsv(file);
  final valid = validateRows(rows);
  await savePrices(valid);
  return summarize(valid);
}
```

## Public surface and privacy
- A package's public API is what `lib/<package_name>.dart` exports (use `show` for partial exports). Everything else lives in `lib/src/` and is not exported.
- Never import another package's `src/` (`implementation_imports`).
- Dart privacy is per library (file). Prefix top-level helpers and members with `_` by default. Drop the `_` only when another file needs the declaration, and even then don't export it unless it's part of the public API.
- Don't use `@visibleForTesting` to open up internals.
- No `part`/`part of` except for generated code.
- Group code by feature: `lib/src/scanning/`, `lib/src/connection/`.

## Layering
- Domain code imports only core `dart:` libraries. Never `package:flutter`, `dart:io`, platform channels or HTTP clients.
- Widgets only map state to UI and user intent to service or state-management calls. No business logic or I/O in widgets.

## Types and null safety
- No `dynamic` in signatures. Untyped data (JSON, channel payloads) arrives as `Object?`; cast and validate it once at the boundary into typed models.
- Prefer `final` fields, `const` constructors and `@immutable` value types. If the codebase uses `freezed` or `equatable`, follow it.
- No `!` in production paths unless the invariant is guaranteed and stated in a comment.
- `late` only for `late final` lazy initializers or fields set in a lifecycle method (e.g. `initState`) before first read.

## Async
- Never drop a `Future`. Await it, or wrap it in `unawaited(...)` when fire-and-forget is intended (`unawaited_futures`, `discarded_futures`).
- Cancel every `StreamSubscription` and close every `StreamController` you create.
- Run CPU-heavy work with `Isolate.run`.

## Error handling
- Throw subclasses of `Exception` (preferably a `sealed class` hierarchy per feature), never strings or bare `Exception('...')`.
- Reserve `Error` subclasses for programmer mistakes.
- Never use a bare `catch (e)` that neither handles nor rethrows.
- Every `// ignore:` gets a comment explaining why.

## Before finishing
- Run `dart format .` and `flutter analyze` (or `dart analyze`); no new issues.
- Follow `analysis_options.yaml`.
