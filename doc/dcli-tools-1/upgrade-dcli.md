# Upgrade DCli

When a new version of DCli is released you will want to upgrade to the latest version.

Any of your scripts which use DCli will need to have their pubspec.yaml  manually updated  pubspec.yaml with the new version of dcli.

Once you have updated the version you need to run pub upgrade:

```text
pub upgrade
```

If you are using the DCli tools then you will need to upgrade the tools:

We run the same process as we did when installing DCli to upgraded it.

```text
pub global activate dcli
dcli install
```



