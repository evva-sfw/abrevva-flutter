# Tasks

## 1. Align Swift 6 build configuration

- [x] 1.1 Update `ios/abrevva.podspec` to declare Swift 6, then verify the generated CocoaPods plugin target uses Swift 6 and resolves the pinned Swift 6 SDK dependency.
- [x] 1.2 Reconcile Debug, Release, and Profile Swift settings for Runner and RunnerTests in `example/ios/Runner.xcodeproj/project.pbxproj`; verify every app/test configuration that builds Swift uses Swift 6 without unintentionally changing supported iOS deployment targets.

## 2. Port plugin concurrency boundaries

- [x] 2.1 Compile the plugin in Swift 6 mode and audit `AbrevvaPlugin`, `AbrevvaBle`, and `AbrevvaCodingStation`; keep channel calls main-actor isolated, document narrowly needed Flutter protocol compatibility annotations, and verify no actor/sendability diagnostics remain.
- [x] 2.2 Update `AbrevvaCrypto` asynchronous URL-session result delivery to safely return on the main actor and make any required Flutter protocol conformance isolation explicit; verify existing success/error payload behavior and exactly-once completion.
- [x] 2.3 Review BLE SDK callback-to-event/result paths and remove avoidable dispatch/force-unwrapped shared state where needed for Swift 6 safety; verify all `FlutterResult`/`FlutterEventSink` calls execute on the main actor and stream payloads remain unchanged.

## 3. Validate

- [x] 3.1 Run `flutter build ios --debug --no-codesign` from `example/` and resolve plugin-owned Swift 6 errors/warnings; record any external dependency/toolchain blocker distinctly.
- [x] 3.2 Run the documented iOS test suite from `example/ios/` on an available simulator and verify tests compile in Swift 6 mode; if unavailable, record the exact environment limitation.
- [x] 3.3 Run configured SwiftLint/SwiftFormat checks and inspect the final diff to confirm only plugin-owned source and relevant iOS build settings changed.

**Validation note:** SwiftLint passes the changed plugin Swift sources. SwiftFormat passes the new compatibility helper and crypto test file; whole-file formatting checks on the legacy plugin files and SwiftLint on the legacy Quick test suite report existing style violations, so no broad formatting cleanup was included.
