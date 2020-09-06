# Upgrade DCli

When a new version of DCli is released you will want to upgrade to the latest version.

For any of your scripts which use DCli you will need to update the local pubspec.yaml dependency section wit the new version of dcli.

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

If you have been using a Shebang or the dcli tools you can also run cleanall to update all of your scripts at once:

```text
dcli cleanall
```

