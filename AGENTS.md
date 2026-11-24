# AGENTS.md

## Workflow
- Always use a spec framework like `openspec` to first propose any requested change. Never touch code without a specification.
- If asked for feedback before drafting the actual proposal, use a grilling skill if available, otherwise ask 1-2 questions to sharpen the initial input.
- If asked for a commit, use a conventional-commit skill if available. Create the commit from staged changes. Never push commits on your own.

## Priority when rules conflict
1. Correctness and the task as given
2. Existing patterns in this codebase (match the surrounding code over the standards)
3. The standards linked below

## Layout and commands
| Path | Language | Contents | Format / lint / build |
|---|---|---|---|
| `ios/` | Swift | iOS implementation and `FlutterPlugin` entry class. | `flutter build ios --debug --no-codesign` in `example/` (macOS only) |
| `android/` | Kotlin | Android implementation and `FlutterPlugin` entry class. | `flutter build apk --debug` in `example/`; `./gradlew lint` in `example/android/` |
| `lib/` | Dart | Public API (`lib/abrevva.dart`) and implementation (`lib/src/`). | `dart format .`, `flutter analyze` |
| `example/` | Dart | Example app that uses the public API. | as `lib/` |

If you can't build iOS in your environment, say so in your summary.

This is a Flutter plugin. Each language folder has its own `AGENTS.md` with the standards to read before editing there.

## Standards
All paths are relative to the repo root. Before writing code, read the files that apply. Don't edit files in `docs/agent-standards/`; they are copied from the shared standards repo.

- Always: `docs/agent-standards/general/` (`code-structure.md`, `doc-comments.md`, `testing.md`).
- Swift files: `docs/agent-standards/swift/` (`code-structure.md`, `doc-comments.md`, `testing.md`).
- Kotlin files: `docs/agent-standards/kotlin/` (`code-structure.md`, `doc-comments.md`, `testing.md`).
- Dart files: `docs/agent-standards/dart/` (`code-structure.md`, `doc-comments.md`, `testing.md`).
- Plugin entry classes or the channel layer: `docs/agent-standards/flutter-plugin/entry-layers.md` and `docs/agent-standards/flutter-plugin/testing.md`.
- Channel names, method names, argument keys or error codes: `docs/agent-standards/flutter-plugin/channel-contract.md`.

In your final summary, list the standards files you followed.

## Tests
| Language | Tests live in | Run |
|---|---|---|
| Swift | `example/ios/RunnerTests/` | `xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=<simulator>'` in `example/ios/` (macOS only) |
| Kotlin | `android/src/test/kotlin/` | `./gradlew :abrevva:testDebugUnitTest` in `example/android/` (build the example once first) |
| Dart | `test/` | `flutter test` (or `flutter test test/path/to/file_test.dart`) |
