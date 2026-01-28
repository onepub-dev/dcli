@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_sdk/src/script/entry_point.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('dcli doctor', () async {
    await TestFileSystem().withinZone((fs) async {
      var exit = -1;
      try {
        exit = await EntryPoint().process(['doctor']);
      } on DCliException catch (e) {
        print(e);
      }
      expect(exit, equals(0));
    });
  });
}
