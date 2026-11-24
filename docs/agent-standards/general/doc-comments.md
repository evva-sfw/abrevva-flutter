# Doc comments (all languages)

Applies to all code. The syntax for each language is in `swift/doc-comments.md`, `kotlin/doc-comments.md` and `dart/doc-comments.md`.

## General rules
- Every declaration that needs documentation gets a real doc comment that the language's doc tool picks up (DocC, KDoc/Dokka, dartdoc). Never a plain `//` comment.
- End every sentence and every callout/tag description with a period.
- Describe meaning, not type. "`true` if the device accepted the connection" beats "Success `Bool`".
- Never restate the summary in the discussion, and never pad a comment to reach a line count.

## Structure of a function comment
Every language uses the same parts, in this order:
1. **Summary:** one sentence saying what the function does.
2. **Discussion (optional, 1–2 lines):** only for something the parts below don't cover, e.g. side effects, threading/actor/isolate context, cancellation, ordering or a non-obvious constraint.
3. **Parameters:** every parameter, in declaration order. For callbacks, say when they are called and on which thread/actor/isolate.
4. **Return value:** whenever the function returns something. Say what the value means, including when it is `null`/`nil` or `false`.
5. **Errors:** every error/exception type the function throws, and when.

If a function has no parameters, returns nothing and doesn't throw, the discussion is required (1–2 lines) and must add something beyond the summary.

## Coverage tiers

| Declaration | Comment |
|---|---|
| Function or method with logic | Full function comment (structure above). |
| Class, struct, actor, object, enum, mixin or extension with behavior; computed property or getter with logic | **2–3 lines.** Line 1 is the summary. Lines 2–3 add responsibilities, lifecycle, thread-safety/isolation or a non-obvious constraint. No callouts or tags. |
| Protocol/interface, data-only type, type alias/typedef, constant | **Exactly one line.** |
| Anything in the *Skip* list | No comment. |

## Skip
- Initializers and constructors, including ones that only inject or assign dependencies.
- Members that only satisfy a protocol/interface requirement with no extra logic: `==`, hashing, `toString`/`description`, `CodingKeys`, SwiftUI `body`, Flutter widget `build`.
  - Framework callbacks that contain logic (lifecycle methods, method-call handlers) are **not** skipped.
- Generated code.
- Preview blocks (`#Preview`).
- Test cases.
