import 'package:dcli/dcli.dart';

/// Wipes the entire HOME/.dcli directory tree.
void wipe() {
  final dcliPath = Settings().pathToDCli;
  if (exists(dcliPath)) {
    deleteDir(dcliPath);
  }
}
