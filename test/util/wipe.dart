import 'package:dshell/functions/delete_dir.dart';
import 'package:dshell/functions/env.dart';
import 'package:path/path.dart';

/// Wipes the entire HOME.dshell directory tree.
void wipe() {
  deleteDir(join(env('HOME'), '.dshell'), recursive: true);
}
