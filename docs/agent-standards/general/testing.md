# Testing (all languages)

Applies to all code. Language files (`swift/testing.md`, `kotlin/testing.md`, `dart/testing.md`) name the frameworks and idioms. A project's own `AGENTS.md` can restrict or override these rules (e.g. "don't write tests in this folder yet"); follow it.

## Frameworks
- Use the test framework, mocking library and patterns the project already uses. Read a few existing tests next to the code you change before writing new ones.
- Don't add new test dependencies or a second framework without asking.

## When to write and update tests
- **New functionality:** add unit tests covering the meaningful success, failure, boundary and interaction cases.
  - Success: the expected result for typical input.
  - Failure: every error the code throws or reports, and how it reacts when a dependency fails.
  - Boundary: empty, zero, minimum/maximum, `null`/`nil`, timeouts, cancellation.
  - Interaction: what the code calls on its dependencies, with which arguments and how often, where that is part of the behavior.
- **Refactoring or changing behavior:** update the relevant existing tests so they describe the intended behavior, and keep their coverage.
- Never delete, skip or loosen a test just to make it pass. If a test encodes behavior the task deliberately changes, update it and say so in your summary.

## What to test and how
- Test behavior through a unit's API, not its private implementation details.
- Test pure functions and value types directly, without doubles.
- Replace only I/O boundaries (network, persistence, clock, platform APIs, platform channels) with test doubles. These are the protocols/interfaces from the I/O-boundary exception in `general/code-structure.md`.
  - **Mock** (generated or library-based): when the test checks calls and arguments.
  - **Fake** (small hand-written implementation): when the boundary has state or the mocking library can't express it safely (non-thread-safe or non-Sendable platform types).
- Never widen access just so a test can reach something. Language mechanisms for tests (Swift `@testable import`, Kotlin `internal` in the same module) are fine.
- One behavior per test. Name tests after the behavior: "throws notConnected when the transport fails", not "testConnect2".
- Structure each test as arrange, act, assert, separated by blank lines.
- Each test creates its own instances. No state shared between tests.

## Determinism
- No real waiting (`sleep`, `delay`, `Future.delayed`, polling loops). Use the framework's virtual time, confirmations or expectations.
- No real network, filesystem outside a temp directory, current time or randomness. Inject a clock, random source or dispatcher instead.
- Tests pass in any order and in parallel.
- Tests compile and run without new warnings under the project's concurrency and analyzer settings.

## Before finishing
- Run the tests covering your change (the project's `AGENTS.md` has the commands). Fix failures before finishing.
- In your summary, say which tests you added or changed and which you ran, with the result. If you couldn't run them (e.g. iOS tests without macOS), say so.
