# Code structure (all languages)

Applies to all code. Language files (`swift/`, `kotlin/`, `dart/`) override these rules where they differ.

## Scope
- Only restructure code you are already changing for the task. Do not refactor unrelated files unprompted.
- If existing code badly violates these rules and blocks the task, say so in your summary instead of silently rewriting it.
- Where the surrounding code follows a different pattern than these rules, match the surrounding code.

## Functions
- Each function does one thing at one level of abstraction. If describing it needs "and", it does two things.
- Soft limit: ~30 lines of body. Above that, extract named steps. Never pass ~50 lines without a stated reason.
- Max nesting depth 2. Use guard clauses and early returns instead of nested `if`/`else`. Each language file names its idiom.
- Max 3 parameters without default values. Beyond that, take a single options type. Argument labels and named parameters do not make a long parameter list acceptable.
- A top-level function reads like a summary of its steps:

```text
importPrices(file):
  rows  = parseCsv(file)
  valid = validateRows(rows)
  savePrices(valid)
  return summarize(valid)
```

- Separate computation from side effects. Pure functions and value types transform data. A thin outer layer does I/O: persistence, network, filesystem, platform channels, current time, randomness, key-value stores, notifications.

## When NOT to split
- Do not extract a helper that is called once and is under ~5 lines, unless it gives a complex expression a meaningful name.
- Do not create a protocol, interface, abstract class, base class, factory or generic for a single implementation. Add the abstraction when the second real use appears.
  - Exception: a protocol/interface at an I/O boundary (network client, persistence, clock, platform channel, system framework wrapper) that tests need to replace. The test double counts as the second use.
- Do not split one cohesive concept across files just to make the files smaller.

## Modules and files
- Group code by feature/domain (`scanning/`, `pricing/`), not by technical kind (`helpers/`, `utils/`, `extensions/`, `models/` at the root).
- One primary responsibility per file. Soft limit ~300 lines; above that, split along a responsibility boundary, not arbitrarily.
- Each module has a deliberate public surface, defined by access control and exports, not by a file you create. Other modules use only that surface, never another module's internals.
- No `Utils` grab-bag files and no catch-all extension files. An extension lives in the feature that owns its concept, or in a clearly named shared module (e.g. `shared/date/`).

## Coupling
- Dependencies point one way: entry layer (UI, plugin entry class, API handlers) → services → domain → nothing. Domain code imports no UI, platform, persistence or networking code.
- No circular dependencies between modules, packages or targets. If two modules need each other, extract the shared part into a third module or invert the dependency.
- Receive dependencies through the constructor/initializer (or parameters). Do not reach for singletons or instantiate concrete services or clients inside the function.
- Pass the data a function needs, not a large object it digs into (`calculateFee(amount, tier)`, not `calculateFee(order)` that reads `order.customer.account.tier`).
- No shared mutable global or static state. Configuration is read once at the edge (app entry point / composition root) and passed in.

## Before finishing
- Check your diff against this list:
  - No function over the soft limit without a stated reason.
  - No new circular dependencies.
  - No use of another module's internals.
  - No single-use abstractions added.
  - No access level widened without need.
- Every function you added or changed has a doc comment that matches its current signature (see `general/doc-comments.md` and the language file).
- Tests are added or updated and the relevant ones pass (see `general/testing.md`).
- Build the project and confirm there are no new compiler, analyzer or lint warnings.
- Run the lint and format tools configured in the project.
