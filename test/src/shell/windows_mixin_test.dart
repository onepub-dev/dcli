@TestOn('windows')

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('loggedInUsersHome ...', () async {
    final drive = env['HOMEDRIVE'];
    final path = env['HOMEPATH'];
    final home = '$drive$path';
    expect((Shell.current as WindowsMixin).loggedInUsersHome, home);
  });
}
