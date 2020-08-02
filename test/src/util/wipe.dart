
import 'package:dshell/dshell.dart';

/// Wipes the entire HOME/.dshell directory tree.
void wipe() {
  var dshellPath = Settings().dshellPath;
  if (exists(dshellPath)) {
    deleteDir(dshellPath, recursive: true);
  }
}
