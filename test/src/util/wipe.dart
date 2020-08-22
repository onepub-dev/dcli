import 'package:dcli/dcli.dart';

/// Wipes the entire HOME/.dcli directory tree.
void wipe() {
  var dcliPath = Settings().dcliPath;
  if (exists(dcliPath)) {
    deleteDir(dcliPath, recursive: true);
  }
}
