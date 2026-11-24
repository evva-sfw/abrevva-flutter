# Design

## Context

See `proposal.md` for the motivation. The example's customized `AppDelegate` now conforms to `FlutterImplicitEngineDelegate` and synchronously registers generated plugins from `didInitializeImplicitFlutterEngine`. Flutter declares this callback in an Objective-C protocol without actor annotations, while the app delegate inherits UIKit's main-actor isolation through `FlutterAppDelegate`; Swift 6 rejects the conformance. The Flutter engine currently invokes the callback synchronously from `FlutterViewController` setup after creating the engine shell. The UIScene migration also removed `@main`, leaving the Runner target without a Swift entry point and causing the linker to report `Undefined symbol: _main`.

## Goals / Non-Goals

**Goals:**
- Resolve the imported-protocol isolation mismatch at the narrow AppDelegate conformance boundary.
- Retain synchronous plugin registration through `engineBridge.pluginRegistry` during implicit-engine initialization.
- Preserve the user's UIScene migration edits, keep `@main` on `AppDelegate` as the Runner target's Swift entry point, and retain all plugin channel behavior.

**Non-Goals:**
- Revert UIScene migration or move registration back to `didFinishLaunchingWithOptions`.
- Weaken Swift 6 mode or strict concurrency settings.
- Change the Flutter SDK, plugin implementation, or SDK repository.

## Decisions

1. **Apply compatibility to the specific Objective-C conformance.** Use Swift's `@preconcurrency` annotation on the `FlutterImplicitEngineDelegate` conformance, with an adjacent comment explaining that the imported Flutter protocol omits actor isolation. This is narrower than annotating the whole Flutter import or suppressing concurrency diagnostics project-wide, and matches the existing plugin's compatibility treatment of Flutter's Objective-C protocols.

2. **Keep the engine callback synchronous and actor-isolated.** Do not wrap plugin registration in an unstructured `Task` or dispatch it asynchronously to the main queue. The callback is the migration's required registration point, and delaying registration could let engine startup continue before plugins are available. Flutter invokes it synchronously from Flutter view-controller setup; retain that timing and rely on the UIKit main-thread lifecycle for the inherited actor isolation.

3. **Keep `AppDelegate` as the Swift application entry point.** Retain the existing `@main` attribute on `AppDelegate` alongside `@objc`; the Runner target has no separate Swift entry point, and removing `@main` causes the linker to fail with `Undefined symbol: _main`.

4. **Validate the user-visible integration through the iOS build.** Re-run the exact Flutter iOS build and confirm both the protocol-conformance diagnostic and missing-entry-point linker error are gone. Do not introduce a test-only abstraction around Flutter's lifecycle callback solely to exercise protocol dispatch.

## Risks / Trade-offs

- [The imported Objective-C protocol does not formally encode its callback's actor contract] → Keep the conformance annotation narrow, preserve the synchronous UIKit setup path, and verify the callback implementation remains limited to plugin registration.
- [Flutter SDK importer behavior can vary across versions] → Validate using the project's configured Flutter SDK and avoid disabling Swift 6 checking for unrelated code.

## Migration Plan

1. Preserve the existing `AppDelegate` UIScene changes, retain `@main` as the Runner target's Swift entry point, and keep the narrowly scoped protocol compatibility annotation and rationale.
2. Run `flutter build ios --debug --no-codesign` and confirm the isolation diagnostic and missing-entry-point linker error are resolved.
3. Inspect the final AppDelegate diff to ensure `@main` remains on `AppDelegate` and generated-plugin registration remains synchronous in `didInitializeImplicitFlutterEngine`.
4. If the annotation does not compile with the configured Flutter SDK, stop and reassess the protocol boundary rather than weakening target-wide concurrency settings.
