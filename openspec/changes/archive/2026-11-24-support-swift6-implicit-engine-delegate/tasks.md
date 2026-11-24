# Tasks

## 1. Resolve AppDelegate protocol isolation

- [x] 1.1 Add a narrowly scoped `@preconcurrency` annotation to the `FlutterImplicitEngineDelegate` conformance in `example/ios/Runner/AppDelegate.swift`, with a comment explaining the imported Objective-C protocol's missing actor annotation; verify the callback stays synchronous and generated plugins remain registered through `engineBridge.pluginRegistry`.
- [x] 1.2 Restore `@main` on `AppDelegate` as the Runner target's Swift application entry point; verify the app delegate remains the declared Swift entry point.

## 2. Validate the example iOS integration

- [x] 2.1 Run `flutter build ios --debug --no-codesign` from `example/` and verify both the `ConformanceIsolation` and `Undefined symbol: _main` errors are gone and the build succeeds.
- [x] 2.2 Review the final AppDelegate diff and verify the UIScene migration, `@main` application entry point, implicit-engine registration timing, and plugin channel behavior are preserved.
