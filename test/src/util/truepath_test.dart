import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
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
    skip: Platform.isWindows,
  );

  test(
    'Windows rootPath',
    () {
      final drive = pwd[0];
      expect(rootPath, equals('$drive:\\'));
    },
    skip: !Platform.isWindows,
  );
}
