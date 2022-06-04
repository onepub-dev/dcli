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
