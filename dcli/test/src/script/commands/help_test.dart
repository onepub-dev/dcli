@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/src/script/entry_point.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  group('Show Help', () {
    test('Help', () {
      TestFileSystem().withinZone((fs) {
        EntryPoint().process(['help']);
      });
    });
  });
}
