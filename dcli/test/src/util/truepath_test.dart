/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:test/test.dart';

void main() {
  test('truepath ...', () async {
    expect(truepath(join(rootPath, 'tmp')), equals(absolute(rootPath, 'tmp')));
    expect(
      truepath(join(rootPath, 'tmp', '..', 'tmp')),
      equals(absolute(rootPath, 'tmp')),
    );
    expect(
      truepath(join(rootPath, 'tmp', '..', 'tmp', '.')),
      equals(absolute(rootPath, 'tmp')),
    );
    expect(
      truepath(join(rootPath, 'tmp', '.')),
      equals(absolute(rootPath, 'tmp')),
    );
    expect(
      truepath(join(rootPath, 'Local')),
      equals(absolute(rootPath, 'Local')),
    );
  });

  test(
    'Posix rootPath',
    () {
      expect(rootPath, equals('/'));
    },
    skip: core.Settings().isWindows,
  );

  test(
    'Windows rootPath',
    () {
      final drive = pwd[0];
      expect(rootPath, equals('$drive:\\'));
    },
    skip: !core.Settings().isWindows,
  );
}
