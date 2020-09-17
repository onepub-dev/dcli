# Dependency Management

## Dependency Management

Dart has a large collection of built in packages. You can read about the core packages at:

[https://dart.dev/guides/libraries/library-tour](https://dart.dev/guides/libraries/library-tour)

However, sometimes you need a specialised package.

There are thousands of third party packages that you can use in your DCli scripts which can be found at:

[https://pub.dev/packages](https://pub.dev/packages)

{% hint style="warning" %}
NOTE: you can't use Flutter or web packages in your DCli scripts.
{% endhint %}

To use an external package you need to add it as a dependency to your script.

Dart's dependency management is done via a pubspec.yaml file.

Each package includes install instructions which is simply a matter of adding a dependency line to your pubspec and running:

`dcli prepare`.

