# DCli tools

DCli ships with a no. of option command line tools to help you creating and writing DCli scripts.

If you are just using the DCli library then you can safely ignore the DCli tools.

If you want to use the DCli tools then you must first install them:

```bash
dart pub global activate dcli
dcli install
```

You can see a full list of `dcli` commands and arguments by running:

```text
dcli 
dcli help
dcli help <command>
```

The syntax of `dcli` is:

```text
dcli [flag, flag...] [command] [flag, flag...] [arguments...]
```

## flags

DCli supports a global verbose flag: `--verbose | -v`

When passed to dcli it will result in additional logging being written to the cli.

```text
dcli -v create hello.dart
```

