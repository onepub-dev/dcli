# Internal Workings

The DCli public API is almost 100% from of Dart Futures and async statements.

This is intentional as Futures provide almost no benefit in cli applications and actually make it harder to write cli apps.

The Dart api has a single function which can only be used on cli applications which is called 'waitFor'.

The 'waitFor' function essentially removes Futures.

DCli relies heavily on the 'waitFor' function to make writing cli apps easy.

