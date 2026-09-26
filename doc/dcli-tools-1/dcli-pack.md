# DCli Pack

`dcli pack` embeds resources such as images, templates, configuration files, and binaries in generated Dart classes that your application can unpack at runtime.

Place resources in the `resource/` directory at your project root, then run:

```bash
dcli pack
```

You can include external resources through `tool/dcli/pack.yaml`. The command writes a registry and resource classes under `lib/src/dcli/resource/generated/`. Re-running it regenerates that directory and removes obsolete part classes.

Each resource has a parent class and separate part classes containing at most 256 KiB of original data each. Parts are gzip-compressed independently and then Base64-encoded. Packing and `PackedResource.unpack()` process the parts serially, avoiding a whole-file compression or extraction buffer. An empty resource has no parts and unpacks to an empty file.

Use the generated registry and `unpack()` as before; applications do not need to manage the parts themselves. Existing generated Base64 resources remain supported by the updated DCli library. Newly generated compressed classes require a DCli library with `PackedResourcePart` support. The legacy `content` getter is not available on these multipart resources; use `unpack()`.

Compression reduces generated source size for compressible data. Already-compressed data can grow, and compiling the generated source can still require substantial memory even though packing and extraction use bounded chunks.

`dcli pack` generates resources for your source code to use. [`dcli compile --packed`](dcli-compile.md#pack-an-application-into-one-executable) packages the compiled application and its native libraries into one self-extracting executable. It does not run `dcli pack` automatically. Use both commands when you need both steps:

```bash
dcli pack
dcli compile --packed bin/tool.dart
```

See [Assets/Resources](../dcli-api/assets.md) for registry access, unpacking, and external resource configuration.
