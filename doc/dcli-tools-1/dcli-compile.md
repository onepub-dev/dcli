# DCli Compile

The `dcli compile` command compiles Dart scripts into native applications and optionally installs them into your PATH. The resulting application can run on a compatible operating system and architecture without Dart or DCli installed.

```text
dcli compile [--nowarmup] [--install] [--overwrite] [--packed] [<script.dart> ...]
dcli compile [--packed] --package <package-name> [<version>]
```

Specify one or more scripts to compile them individually. If you omit the scripts, DCli compiles all `.dart` files in the current directory.

## Compile and run a script

The executable is created beside the Dart script.

{% tabs %}
{% tab title="Linux / macOS" %}
```bash
dcli compile tool.dart
./tool
```
{% endtab %}

{% tab title="Windows" %}
```powershell
dcli compile tool.dart
.\tool.exe
```
{% endtab %}
{% endtabs %}

Scripts without bundled native libraries produce a standalone executable.

## Native libraries

DCli detects build hooks in the script's resolved packages and uses `dart build cli` to build the application and its native assets. No extra compile flag is needed. The dependencies' hooks may require additional build tools, such as a C compiler.

When the build produces bundled native libraries, DCli creates a native executable launcher beside the script and places the application in a hidden `.tool.bundle/` directory:

```text
project/
  tool.dart
  tool
  .tool.bundle/
    bin/
      tool
    lib/
      libnative.so
```

Run `./tool` as usual. It is an executable binary, not a shell script, and does not require Dart at runtime. The launcher finds its bundle relative to its own location, so it also works when called from another directory.

Dart's required `bin/` and `lib/` layout stays inside the bundle. Even when the script is `project/tool.dart`, DCli keeps the output inside `project/`; it does not create a `lib/` directory above the project. Each application's libraries are kept in its own bundle.

On Windows the launcher is `tool.exe`, the bundle is named `.tool.bundle`, and the application inside `bin/` also has an `.exe` extension. Native library names and extensions depend on the package and platform. The dot prefix makes the bundle hidden on Linux and macOS; it does not set the Windows hidden attribute.

The launcher passes through arguments, standard input, standard output, standard error, the working directory, environment, and exit status. On Linux and macOS it replaces itself with the bundled application, preserving the process ID and signal behavior.

Automatic bundling covers native assets supplied by build hooks. Libraries loaded manually, for example with `DynamicLibrary.open`, still need to be deployed according to the package's instructions, and any required system libraries must be available on the destination machine.

## Pack an application into one executable

Use `--packed` to embed the compiled application and its hook-provided native libraries in one executable:

```bash
dcli compile --packed bin/tool.dart
./bin/tool
```

The output is `bin/tool` (`bin/tool.exe` on Windows). You can copy or rename this file without an adjacent bundle. Default compilation still uses the bundle layout described above. Packed mode also works with `--install` and `--package`.

On first launch, the executable extracts its contents into a private cache. Each file is processed serially in independently gzip-compressed chunks of at most 256 KiB before compression. Later launches verify and reuse the extracted files; missing or corrupted files are extracted again. Concurrent launches share a lock so they do not extract the same bundle simultaneously.

| Platform | Default cache root |
| --- | --- |
| Linux and macOS | `$HOME/.dcli/cache/bundles` |
| Windows | `%USERPROFILE%\.dcli\cache\bundles` |

Each version has a content-derived cache key. The extracted layout is `<cache>/<key>/bin/tool` and `<cache>/<key>/lib/...`, preserving Dart's library lookup layout inside the cache. Set `DCLI_BUNDLE_CACHE` to change the cache root, or `DCLI_BUNDLE_VERBOSE=1` to print extraction and reuse diagnostics to stderr. The cache must be writable and allow executable files. Old versions are retained; you can remove them when the corresponding applications are no longer running.

Packed mode trades an extra compilation step, first-launch extraction, and a disk cache for distributing one file. Chunking bounds the compression and decoding buffers; compiler memory and the resident embedded data can still grow with the application's size. Already-compressed data may grow slightly.

### How this relates to dcli pack

[`dcli pack`](dcli-pack.md) generates Dart classes for application resources such as images and templates. `dcli compile --packed` embeds the **compiled application and its native bundle**. It does not regenerate your resource classes or scan `resource/` or `tool/dcli/pack.yaml` automatically.

If your application uses resources, generate them first and reference the generated registry from your application:

```bash
dcli pack
dcli compile --packed bin/tool.dart
```

Resources referenced by your code are already part of the compiled application and travel with it in either compile mode. Packing unused resource files does not automatically make your application use them.

## Output locations

After compilation, DCli prints the final executable path. Bundle mode also prints the launcher, bundle directory, and every bundled executable, library, and other asset. Temporary compiler output paths are suppressed.

Without `--install`, outputs are beside the source script. With `--install` or `--package`, the reported paths are under `~/.dcli/bin`. Packed mode reports the packed executable; its extraction cache is created at runtime on the receiving machine.

## Install a compiled script

Use `--install` to move the compiled application into `~/.dcli/bin`, which `dcli install` adds to your PATH:

```bash
dcli compile --install tool.dart
tool
```

For an application with bundled native libraries, both parts are installed together:

```text
~/.dcli/bin/
  tool
  .tool.bundle/
    bin/tool
    lib/libnative.so
```

Use `--overwrite` to replace an existing installed application without an overwrite prompt:

```bash
dcli compile --install --overwrite tool.dart
```

For applications with native libraries, replacement includes the complete private bundle, removing obsolete files from the previous bundle.

## Distribute a compiled application

Copy a standalone executable to a compatible machine and run it directly. For an application with native libraries, copy **both the launcher and its hidden bundle**, keeping them beside each other:

```bash
tar -czf tool.tar.gz tool .tool.bundle
```

Include the hidden directory explicitly: a shell wildcard such as `*` normally omits it. Preserve executable permissions when copying or unpacking the application. The receiving machine does not need Dart or DCli.

If you rename `tool` to `mytool`, also rename `.tool.bundle` to `.mytool.bundle`. Leave the executable name inside the bundle unchanged. On Windows, rename `tool.exe` to `mytool.exe` and use `.mytool.bundle` for the directory.

## Compile a package

DCli can compile a globally activated package and install the executables listed in its `pubspec.yaml`:

```bash
dart pub global activate critical_test
dcli compile --package critical_test
critical_test
```

The compiled applications are installed into `~/.dcli/bin`. Applications with bundled native libraries get a native launcher and their own hidden bundle there, just like scripts compiled with `--install`.

You can pass an optional package version after the package name. That version must be available in your pub cache.

Compiling a globally activated package provides faster startup and lets you distribute the application without installing Dart. It also allows the compiled application to keep running independently of later changes to your installed Dart SDK.

{% hint style="info" %}
Ensure `~/.dcli/bin` appears before `~/.pub-cache/bin` in your PATH so the compiled application is selected before the globally activated version.
{% endhint %}

## Flags

### --nowarmup | -nw

Skip the normal warmup before compilation when the script is already ready to run. Use this when its dependencies have not changed. DCli still warms up a script that is not ready to run. Native build hooks still run when needed to build the application.

### --install | -i

Move the compiled executable into `~/.dcli/bin`. If the application has a hidden bundle, move it alongside the launcher.

### --overwrite | -o

Allow replacement of an existing installed executable and its bundle without prompting. This flag is normally used with `--install`.

### --package | -p

Compile a globally activated package and install its applications into `~/.dcli/bin`. This mode installs automatically; `--install` is not required.

### --packed | -pk

Embed the compiled application and its native bundle in a compressed, self-extracting executable. Keep the normal bundle mode by omitting this flag. Run `dcli pack` separately when application resources need regenerating.
