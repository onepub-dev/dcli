/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:test/test.dart';

void main() {
  test('chown ...', () async {
    withTempFile((test) {
      final user = Shell.current.loggedInUser;

      chown(test, group: user, user: user);
    });
  }, tags: ['sudo']);
}
