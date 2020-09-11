# DCli Clean

## DCli clean

DCli clean essentially does the same as a pub upgrade.  It is provided as a convenience function and you can use a pub upgrade/pub get interchangeably with DCli clean.

{% hint style="info" %}
If you edit the pubspec.yaml of your DCli script project then you need to run `dcli clean` so that DCli sees the changes you have made.
{% endhint %}

If you change your pubspec.yaml you can call dcli clean from anywhere in your projects directory structure.

```text
dcli clean 
```

Your scripts are now ready to run.

