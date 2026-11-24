# Android side (Kotlin)

Also follow the root `AGENTS.md`.

Before editing files here, read:
- `docs/agent-standards/kotlin/code-structure.md`
- `docs/agent-standards/kotlin/doc-comments.md`
- `docs/agent-standards/kotlin/testing.md`
- `docs/agent-standards/flutter-plugin/entry-layers.md` (section *Kotlin*)
- `docs/agent-standards/flutter-plugin/testing.md` (section *Kotlin entry class*) when touching the plugin entry class

Commands: `flutter build apk --debug` in `example/`; `./gradlew lint` and any configured Kotlin linters in `example/android/`.
Tests: in `android/src/test/kotlin/`. Run with `./gradlew :abrevva:testDebugUnitTest` in `example/android/`.
