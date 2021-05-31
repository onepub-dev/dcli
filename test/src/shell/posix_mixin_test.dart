@TestOn('posix')

import 'package:dcli/dcli.dart';
import 'package:dcli/src/shell/posix_shell.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('loggedInUsersHome ...', () async {
    final home = join(rootPath, 'home', env['USER']);
    expect((Shell.current as PosixShell).loggedInUsersHome, home);
  });
}
