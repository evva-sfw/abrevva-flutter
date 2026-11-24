# Design

## Context

See `proposal.md` for motivation. The plugin is a CocoaPods library (`ios/abrevva.podspec`, currently declaring Swift 5.0) consumed by a Flutter example app. In `example/ios/Runner.xcodeproj/project.pbxproj`, the app target is Swift 6, but RunnerTests remains Swift 5 and the project-level Profile setting is Swift 6 while other project defaults are unset. `AbrevvaPlugin`, `AbrevvaBle`, and `AbrevvaCodingStation` are main-actor Flutter entry points with `@preconcurrency FlutterPlugin` conformances; `AbrevvaCrypto` is not actor-isolated despite synchronous crypto handlers and an asynchronous URLSession completion that calls a Flutter result callback. The SDK's BLE and coding-station APIs are main-actor isolated and async, and its callback APIs bridge delegate events to `MainActor`.

## Goals / Non-Goals

**Goals:**
- Make the plugin target's Swift language mode explicit and compatible with its Swift 6 SDK dependency.
- Keep Flutter method results and event emissions on the main actor while satisfying Swift 6 concurrency checking.
- Narrow compatibility annotations to actual Objective-C/Flutter protocol boundaries and explain them where required.
- Validate app, plugin, and tests under consistent Swift 6 settings.

**Non-Goals:**
- Change Flutter channel names, method arguments, result shapes, error codes, or event semantics.
- Port or edit the separate `abrevva-sdk-ios` repository.
- Perform unrelated cleanup or API redesign in crypto, BLE, or coding station behavior.

## Decisions

1. **Set Swift 6 mode at the pod target, not only the example app.**
   Update the podspec's Swift version and inspect generated CocoaPods target configuration; align Runner and RunnerTests configurations that compile plugin/example Swift source. Keep the deployment target consistent with the library's existing iOS support. This ensures downstream Flutter apps receive the required compiler mode instead of relying on the example project's settings. Alternative: set only the Runner app to Swift 6; rejected because a plugin is compiled as its own pod target.

2. **Use main-actor isolation for Flutter-facing handlers.**
   Keep method/event-channel interaction on `MainActor`, including `AbrevvaCrypto`'s URLSession callback response path. Prefer actor-isolated `Task` handoffs or async URLSession APIs over ad hoc dispatch when crossing from nonisolated callbacks. Preserve the existing Flutter channel contract and callback completion behavior. Alternative: mark broad types `@unchecked Sendable` or suppress diagnostics with module-wide preconcurrency imports; rejected because mutable plugin state and Flutter callbacks are actor-bound.

3. **Retain only narrowly justified imported-protocol compatibility.**
   Flutter's plugin and stream-handler protocols and Objective-C framework delegate callbacks may not encode actor isolation. Keep a `@preconcurrency` conformance only where required by the compiler, with an adjacent comment describing the framework boundary and ensuring implementations hop to the actor before touching state or invoking sinks/results. Do not blanket-annotate imports or mutable types.

4. **Verify the actual build graph and strictness, not just project-file text.**
   Build the example for iOS and run its iOS tests where available, inspect compiler diagnostics from generated Pods targets, and ensure Debug/Release/Profile app and test configurations agree. Use the configured SwiftFormat/SwiftLint phases without broad formatting changes. Alternative: treat setting `SWIFT_STRICT_CONCURRENCY = targeted` as sufficient; rejected because Swift 6 language mode already enforces complete checking and the plugin pod's own setting is decisive.

## Risks / Trade-offs

- [Flutter and CocoaPods versions may expose Objective-C APIs with incomplete concurrency annotations] → Keep any compatibility annotations minimal, documented, and at the conformance boundary; verify with the actual generated pod build.
- [Moving crypto's URL callback handling to the main actor may alter callback scheduling] → Preserve exactly-once result delivery and channel-visible payload/error behavior, and cover the asynchronous path in tests if test seams permit.
- [Example project has differing deployment targets between project defaults and app target] → Preserve current plugin iOS 16 minimum and avoid unrelated changes to generated/test deployment settings unless the compiler/build graph requires alignment.

## Migration Plan

1. Inspect effective Xcode/CocoaPods settings and resolve target/configuration inconsistencies.
2. Update plugin-facing concurrency annotations and callback handoffs based on strict compiler diagnostics.
3. Build the example iOS app and run available iOS tests; address regressions without changing the channel contract.
4. No runtime migration or rollback step is needed; reverting the podspec and source edits restores the prior compiler mode.
