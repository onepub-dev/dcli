import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  /// This test need to be run under sudo
  test('isPrivligedUser', () {
    Shell.current.isPrivilegedUser;
  }, tags: ['sudo']);

  /// we touch all of the dart files but don't change their ownership.
  // find('*.dart', root: '.').forEach((file) {
  //   print('touching $file');
  //   copy(file, '$file.bak', overwrite: true);
  // });

  // if (exists('/tmp/test')) {
  //   deleteDir('/tmp/test');
  // }
  // createDir('/tmp/test');
  // // do something terrible by temporary regaining the privileges.
  // withPrivileges(() {
  //   print('copy stuff I should not.');
  //   copyTree('/etc/', '/tmp/test');
  // });
}

void privileged({required bool enabled}) {
  /// how do I changed from root back to the normal user.
  if (enabled) {
    print('Enabled root priviliges');
  } else {
    print('Disabled root priviliges');
  }
}

void withPrivileges(void Function() task) {
  privileged(enabled: true);
  task();
  privileged(enabled: false);
}
