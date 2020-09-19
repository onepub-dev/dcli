import 'package:dcli/dcli.dart';

void main() {
  /// reduce the scripts privileges
  privileged(false);

  /// we touch all of the dart files but don't change their ownership.
  find('*.dart', root: '.').forEach((file) {
    print('touching $file');
    copy(file, '$file.bak', overwrite: true);
  });

  if (exists('/tmp/test')) {
    deleteDir('/tmp/test');
  }
  createDir('/tmp/test');
  // do something terrible by temporary regaining the privileges.
  withPrivileges(() {
    print('copy stuff I should not.');
    copyTree('/etc/', '/tmp/test');
  });
}

void privileged(bool enabled) {
  /// how do I changed from root back to the normal user.
  if (enabled) {
    print('enabled root priviliges');
  } else {
    print('disable root priviliges');
  }
}

void withPrivileges(void Function() task) {
  privileged(true);
  task();
  privileged(false);
}
