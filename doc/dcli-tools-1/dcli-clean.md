# DCli Warmup

## DCli Warmup

DCli warmup essentially does the same as a pub upgrade. It is provided as a convenience function and you can use a pub upgrade/pub get interchangeably with DCli warmup.

DCli warmup prepares your project so that you can run any of the project scripts.

When a script is run that have been 'warmed' up, it runs in JIT mode and as such has a slower start time when compared to a compiled script.

The advantage of JIT mode is that it makes it easy to iterate over code changes. You can simple edit your script and immediately run the script.

You only need to run warmup again if you make a change to your dependencies.

If you need faster start times then you should consider compiling your scripts using [`dcli compile`](dcli-compile.md).

{% hint style="info" %}
If you edit pubspec.yaml in your project then you need to run `dcli warmup` so that DCli sees the changes you have made.
{% endhint %}

If you change your pubspec.yaml you can call \`dcli warmup\` from anywhere in your project's directory structure.

```text
dcli warmup
```





