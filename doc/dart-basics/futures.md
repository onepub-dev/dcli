# Futures

## DCli and futures

if your not a Dart programmer \(yet\) one of the most difficult things about Dart are Futures. If you are familiar with Javascript then a Future is the equivalent of a Promise.

### Just ignore Futures

If your not familiar with Dart or Javascript then for the moment you can just ignore futures.

DCli works very hard to ensure that you don't need to worry about Futures.

This is very intentional.

If you stick to using DCli's built in functions then you can completely ignore Futures. If you start importing Dart's core libraries or third party libraries then you need to pay attention to return types.

The first time you try to call a method or function that returns a `Future` then you will know its time to come back here and read about Futures.

Until then, you can just skip this section.

### How DCli manages futures

DCli does not stop you using `await`, `Futures`, `Isolates` or any other Dart functionality. Its all yours to use and abuse as you will.

DClis global functions however intentionally avoid `Futures`.

They aim of DCli is to create a Bash like simplicity cli apps. `Futures` are great and all but they do make the code more complex and harder to read.

Futures also can make your scripts a little dangerous. If you copy a file and then want to append to the copied file, you had better be certain that the copy command has completed before you start the append. DCli's global functions remove those complications.

If you are interested in how we avoid using `Futures` read up on `waitFor` and check out DCli's own `waitForEx` function that does stacktrace repair when an exception is thrown.

When you need to use futures you can read up on them in the Dart language Tour:

[https://dart.dev/guides/language/language-tour](https://dart.dev/guides/language/language-tour)

