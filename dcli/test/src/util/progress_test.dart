@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
// This is intended to demonstrate that we ouput data as it flows in
  // I'm not certain how to actually test that so for the
  // moment this test is disabled.
  test(
    'Slow',
    () async {
      await TestFileSystem().withinZone((fs) async {
        print(pwd);
        'bash ${join(fs.testScriptPath, 'general/bin/slow.sh')}'.forEach(print);
        expect(
          () => 'tail -n 5 badfilename.txt'.run,
          throwsA(isA<DCliException>()),
        );
      });
    },
    skip: true,
  );

  test('toList', () {
    expect(
      find('*', workingDirectory: HOME, recursive: false).toList().length,
      isNot(equals(0)),
    );
  });

  test('forEach', () {
    final list = <String>[];
    find('*', workingDirectory: HOME, recursive: false).forEach(list.add);
    expect(list.length, isNot(equals(0)));
  });
}
