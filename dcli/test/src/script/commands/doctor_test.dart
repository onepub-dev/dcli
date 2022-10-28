@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  test('dcli doctor', () {
    TestFileSystem().withinZone((fs) {
      var exit = -1;
      try {
        exit = EntryPoint().process(['doctor']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}
