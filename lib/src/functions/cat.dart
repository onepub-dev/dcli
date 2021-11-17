import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

export 'package:dcli_core/dcli_core.dart' show CatException;

/// Prints the contents of the file located at [path] to stdout.
///
/// ```dart
/// cat("/var/log/syslog");
/// ```
///
/// If the file does not exists then a CatException is thrown.
///
void cat(String path, {LineAction stdout = print}) =>
    waitForEx(core.cat(path, stdout: stdout));
