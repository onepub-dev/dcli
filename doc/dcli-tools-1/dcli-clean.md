# DCli Prepare

## DCli Prepare

DCli prepare essentially does the same as a pub upgrade. It is provided as a convenience function and you can use a pub upgrade/pub get interchangeably with DCli prepare.

{% hint style="info" %}
If you edit the pubspec.yaml of your DCli script project then you need to run `dcli prepare` so that DCli sees the changes you have made.
{% endhint %}

If you change your pubspec.yaml you can call dcli prepare from anywhere in your projects directory structure.

```text
dcli prepare
```

Your scripts are now ready to run.

