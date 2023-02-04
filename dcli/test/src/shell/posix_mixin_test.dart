/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

@TestOn('posix')
library;

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('loggedInUsersHome ...', () async {
    final home = join(rootPath, 'home', env['USER']);
    expect((Shell.current as PosixShell).loggedInUsersHome, home);
  });
}
