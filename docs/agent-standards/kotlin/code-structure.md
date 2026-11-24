# Kotlin code structure

Applies to all Kotlin code. Read together with `general/code-structure.md`. Where the two differ, this file wins.

## Idioms for the general rules
- **Early returns:** `?: return`, `?: throw` and `when` instead of nested `if` / `?.let` chains.
- **Options type:** a `data class` once a function needs more than 3 parameters without default values. Named arguments don't make a long parameter list acceptable.
- **Singletons to avoid:** `object` singletons and `getInstance()`. Inject the dependency instead.
- **Global state to avoid:** mutable properties in `object` / `companion object`, top-level `var`. `const val` is fine.
- **Side effects to keep in the outer layer:** `System.currentTimeMillis()`, `Clock`, randomness, `SharedPreferences`/DataStore, `Context`, network clients.

```kotlin
suspend fun importPrices(file: File): ImportSummary {
    val rows = parseCsv(file)
    val valid = validateRows(rows)
    savePrices(valid)
    return summarize(valid)
}
```

## Visibility
- Kotlin is public by default, so mark every declaration `private` or `internal` explicitly. Only the module's deliberate API is public.
- Never widen visibility just so another module or a test can reach it (no `@VisibleForTesting` to open up internals).
- Group code in packages by feature (`com.example.app.scanning`), not by kind (`...utils`, `...models`).

## Layering
- Domain code never imports `android.*`, `androidx.*` or framework-specific code (`io.flutter.*`, Retrofit, Room).
- Activities, Fragments and Composables only map state to UI and user intent to view model or service calls. Persistence lives in a per-feature repository.
- Never store `Activity` or a non-application `Context` in an `object`, `companion object` or any long-lived field. Use `applicationContext` for anything long-lived.

## Coroutines
- Use structured concurrency. Every coroutine runs in a scope tied to a lifecycle (`viewModelScope`, `lifecycleScope`, or a scope the owning class creates and cancels).
- No `GlobalScope`, no `runBlocking` in production code.
- Inject `CoroutineDispatcher`s instead of hard-coding `Dispatchers.IO`/`Dispatchers.Default` inside services.
- Never catch `CancellationException` without rethrowing it.

## Null safety and immutability
- No `!!` in production paths unless the invariant is guaranteed and stated in a comment.
- `lateinit` only for fields set in a lifecycle callback; otherwise use constructor injection or `by lazy`.
- Prefer `val`, `data class` and read-only collection types (`List`, `Map`). Expose `StateFlow`/`Flow`, never `MutableStateFlow`/`MutableList`.

## Error handling
- Model errors as a `sealed class`/`sealed interface` hierarchy, or a sealed result type if the codebase already uses one.
- Never swallow exceptions in an empty `catch`.
- No `TODO()` or `error()` in production paths unless the invariant is stated in a comment.
- Every `@Suppress` gets a comment explaining why.

## Before finishing
- Build and confirm no new compiler warnings.
- Run `./gradlew lint` and any configured Kotlin linters (ktlint, detekt, spotless).
