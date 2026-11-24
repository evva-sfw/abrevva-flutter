# Proposal

## Why

The plugin's iOS implementation must compile cleanly with Swift 6 and strict concurrency to consume the newly updated Swift 6 `AbrevvaSDK`. The current Xcode settings are inconsistent across configurations and targets, and several plugin callbacks cross concurrency boundaries without an explicit, safe actor handoff.

## What Changes

- Audit and normalize Swift language and concurrency settings across the plugin pod and example iOS app/test targets, preserving the supported deployment target and avoiding changes to generated or unrelated Xcode settings.
- Port the plugin's Swift entry and callback code to Swift 6 concurrency: keep Flutter channel callbacks on the main actor, safely handle SDK callbacks and asynchronous results, and document any narrowly necessary compatibility annotations.
- Validate with iOS build/test commands and address compiler concurrency diagnostics in plugin-owned code; do not modify the separate SDK repository.

## Capabilities

### New Capabilities

None. This is a compatibility/tooling and implementation-hardening change; it does not introduce externally observable behavior.

### Modified Capabilities

None.

## Impact

- `ios/Classes/*.swift` plugin implementation.
- `ios/abrevva.podspec` and example iOS Xcode build settings where necessary.
- Existing Flutter method/event channel behavior remains unchanged.
- The plugin consumes the Swift 6 `AbrevvaSDK` dependency; the SDK source at `/Users/palic/Work/Repositories/ghe/abrevva-sdk-ios` is reference context only and is out of scope for edits.
