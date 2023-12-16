/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
      Resources().pack();
    }, progress: Progress.capture());

    expect(progress.lines.contains(green('Pack complete')), isTrue);
  });

  test('resource no exclude', () async {
    withTempDir((tempDir) {
      Scope()
        ..value(Resources.scopeKeyProjectRoot, tempDir)
        ..runSync(() {
          createDir(dirname(Resources.pathToPackYaml), recursive: true);
          // ignore: cascade_invocations
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

  //   withTempFile((file) {
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
