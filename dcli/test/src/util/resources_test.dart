/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

//import 'package:dcli/src/dcli/resource/generated/resource_registry.g.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:scope/scope.dart';
import 'package:test/test.dart';

/// const filename = 'PXL_20211104_224740653.jpg';

void main() {
  test('resource ...', () async {
    final progress = await capture(() async {
      await withTempDirAsync((tempDir) async {
        Scope()
          ..value(Resources.scopeKeyProjectRoot, tempDir)
          ..runSync(() {
            Resources().pack();
          });
      });
    }, progress: Progress.capture());

    expect(progress.lines.contains(green('Pack complete')), isTrue);
  });

  test('resource no exclude', () async {
    await withTempDirAsync((tempDir) async {
      Scope()
        ..value(Resources.scopeKeyProjectRoot, tempDir)
        ..runSync(() {
          createDir(dirname(Resources.pathToPackYaml), recursive: true);
          Resources.pathToPackYaml.write('''
externals:
  - external:
    path: ../template
    mount: template
''');

          Resources().pack();
        });
    });
  });

  // test('unpack', () {
  //   final jpegResource = ResourceRegistry.resources[filename];
  //   expect(jpegResource, isNotNull);

  //   await withTempFileAsync ((file) {
  //     final root = Resources().resourceRoot;
  //     final pathTo = join(root, filename);
  //     final originalHash = calculateHash(pathTo);
  //     jpegResource!.unpack(file);
  //     final unpackedHash = calculateHash(file);
  //     expect(originalHash, equals(unpackedHash));
  //   });

  // for (var resource in ResourceRegistry.resources)
  // {

  // }
  // });
}
