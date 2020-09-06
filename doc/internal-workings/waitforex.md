# waitForEx

## waitForEx

DCli goes to great lengths to remove the need to use `Futures` and `await;`there are two key tools we use for this.

`waitFor` and `streams`.

`waitFor` is a fairly new Dart function which ONLY works for Dart CLI applications and can be found in the `dart:cli` package.

The DCli API doesn't expose any futures despite using futures extensively in its internal workings.

`waitFor` allows a Dart CLI application to turn what would normally be an async method \(returning a future\) into a normal synchronous method by effectively 'absorbing' a future. Normally in Dart, as soon as you have one async function, its async all of the way up.

DCli simply wouldn't have been possible without `waitFor.`

`waitFor` does however have a problem. If an exception gets thrown whilst in a `waitFor` call, then the stacktrace generated will be a microtask based stack trace. These stacktraces are useless as they don't show you where the original call came from.

This is why `waitForEx` was born. `waitForEx` is my own little creation that does three things.

1. capture the current stack using StackTraceImpl
2. calls `waitFor` and catches any exceptions
3. If an exception is thrown it patches the stack trace captured in 1 and merges it with the interesting bits of the microtask exception.

The result is that you get a clean stacktrace that points to the exact line that cause the problem and we have a stacktrace that actually shows where it was called from.

