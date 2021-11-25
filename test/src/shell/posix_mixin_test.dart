@TestOn('posix')

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart';
import 'package:test/test.dart';

void main() {
  test('loggedInUsersHome ...', () async {
    final home = join(rootPath, 'home', env['USER']);
    expect((Shell.current as PosixShell).loggedInUsersHome, home);
  });
}
