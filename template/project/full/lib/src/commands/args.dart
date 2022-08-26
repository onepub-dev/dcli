import 'package:dcli/dcli.dart';

class Args {
  // We parse and global Args here
  Args(ArgResults? argResults) {
    Settings().setVerbose(enabled: argResults!['debug'] as bool);
  }
}
