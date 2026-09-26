# Packed bundle benchmark

The production command is `dcli compile --packed tool.dart`. Default compilation retains the native launcher and adjacent hidden bundle. Both `dcli pack` and packed compilation now use independently gzip-compressed parts containing at most 256 KiB of original data per generated class.

The helper in this directory packages an **existing** bundle using the same production builder. Supply a bundle with exactly one executable in `bin/`, containing regular files and directories (including hidden files). Symbolic links and the root filename `.complete` are rejected.

```bash
dart run tool/prototype/single_file.dart \
  --build-dir /tmp/op-ssh-packed-sources \
  /path/to/project/bin/.op-ssh.bundle \
  /path/to/output/op-ssh
```

Use a new build directory. It retains generated sources and `metrics.json`. Without `--build-dir`, temporary sources are removed after compilation.

## Extraction

A packed executable extracts serially into a private, content-addressed cache with the layout `<cache>/<key>/bin/<app>` and `<cache>/<key>/lib/<libraries>`. A per-key lock serializes concurrent extractions. Length and CRC32 checks detect missing or corrupted files, including on warm starts. A staging directory is renamed into place after extraction succeeds. Abandoned staging directories for that key are removed at the next launch.

Default cache roots are `$XDG_CACHE_HOME/dcli/bundles` (falling back to `$HOME/.cache/dcli/bundles`) on Linux, `$HOME/Library/Caches/dcli/bundles` on macOS, and `%LOCALAPPDATA%/dcli/bundles` on Windows. Override the root with `DCLI_BUNDLE_CACHE`; set `DCLI_BUNDLE_VERBOSE=1` for diagnostics. Old cached versions are not automatically evicted.

Compression and decoding process one chunk at a time. Embedded constants and compiler allocations still contribute to memory use, so this does not promise constant total RSS for arbitrarily large binaries. Warm launches verify cached bytes but do not decode the embedded resources.

## Measurements

Single samples on Linux x64 with Dart 3.13.0. The fixture calls a C shared library and prints `42`. The larger case adds 64 MiB of incompressible random data. Sizes use MiB (1,048,576 bytes).

| Input bundle | Generated Dart source | Packed executable | Cold time | Cold peak RSS | Warm time | Warm peak RSS |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 6.2 MiB | 3.9 MiB | 9.9 MiB | 0.11 s | 24.1 MiB | 0.04 s | 9.2 MiB |
| 70.2 MiB | 99.0 MiB | 95.4 MiB | 1.31 s | 103.0 MiB | 0.36 s | 20.8 MiB |

The small executable still exceeds the input bundle because it includes a second Dart runtime for the launcher. Incompressible payloads still incur Base64 and generated-source overhead. The former uncompressed prototype produced 101.4 MiB for the larger case and extracted in 1.71 seconds; it did less validation on warm starts, so its warm timings are not directly comparable.

Peak build RSS was 785 MiB and 855 MiB respectively. Launcher compilation took 1.4 and 7.4 seconds; complete packaging commands took 12 and 28 seconds including tool startup. Chunking avoids giant individual classes and whole-file compression buffers but does not eliminate the Dart compiler's memory requirements. These samples do not establish a maximum supported resource size.

The existing `op-ssh` bundle (17.2 MiB) produced 10.1 MiB of generated source and a 15.5 MiB executable, compared with 29.8 MiB for the earlier uncompressed prototype. Its SSH workflow was not executed.

Reproduce with Dart, a C compiler, Python 3, and GNU time on Linux:

```bash
python3 tool/prototype/benchmark.py \
  --output-dir /tmp/dcli-pack-measurements \
  --sizes 0 16 64
```

Use a new output directory. It retains source, executables, raw timings, and `results.json`.

## Tests

```bash
dart test test/src/util/packed_resource_test.dart \
  test/src/util/resource_packer_test.dart \
  test/src/script/native_compile_test.dart
```

The SDK's `test/src/commands/packed_compile_test.dart` also exercises `dcli pack` followed by `dcli compile --packed`, verifies compilation does not implicitly repack resources, and runs the relocated executable without its original project.

Runtime validation here was on Linux. macOS and Windows execution still need verification on those platforms.
