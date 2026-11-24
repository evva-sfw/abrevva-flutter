# iOS side (Swift)

Also follow the root `AGENTS.md`.

Before editing files here, read:
- `docs/agent-standards/swift/code-structure.md`
- `docs/agent-standards/swift/doc-comments.md`
- `docs/agent-standards/swift/testing.md`
- `docs/agent-standards/flutter-plugin/entry-layers.md` (section *Swift*)
- `docs/agent-standards/flutter-plugin/testing.md` (section *Swift entry class*) when touching the plugin entry class

Commands: `flutter build ios --debug --no-codesign` in `example/` (macOS only); SwiftLint/SwiftFormat if configured.
Tests: in `example/ios/RunnerTests/`. Run with `xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=<simulator>'` in `example/ios/` (macOS only).
