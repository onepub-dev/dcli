import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('chown ...', () async {
    final test = FileSync.tempFile();
    touch(test, create: true);
    final user = Shell.current.loggedInUser;

    chown(test, group: user, user:user);
  });
}
