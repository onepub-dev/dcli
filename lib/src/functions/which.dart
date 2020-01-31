import '../../dshell.dart';
import '../util/progress.dart';
import 'package:path/path.dart' as p;

import 'dshell_function.dart';
import 'env.dart';

///
/// Searches the PATH for the location of the application
/// give by [appname].
///
/// The search is conducted by searching each of the
/// paths in the environment variable 'PATH' from
/// left to right (start to end) as this is the
/// same order the OS searches the path.
///
/// If the [verbose] flag is true then a line is output
/// for each path searched.
///
/// It is possible that more than one copy of the
/// appliation is found.
///
/// [which] returns a list of paths that contain
/// appname in the order they were found.
///
/// The first path in the list is the one the OS
/// will be using.
///
/// if the [first] flag is true then which will
/// stop searching as soon as it finds a match.
/// [first] is true by default.
///
/// ```dart
/// which('ls', first: false, verbose: true);
/// ```
///
Progress which(String appname,
        {bool first = true, bool verbose = false, Progress progress}) =>
    Which().which(appname, first: first, verbose: verbose, progress: progress);

class Which extends DShellFunction {
  ///
  /// Searches the path for the given appname.
  Progress which(String appname,
      {bool first, bool verbose, Progress progress}) {
    Progress forEach;

    try {
      forEach = progress ?? Progress.forEach();

      for (var path in PATH) {
        if (verbose) {
          forEach.addToStdout('Searching: ${p.canonicalize(path)}');
        }
        if (exists(p.join(path, appname))) {
          forEach.addToStdout('${p.canonicalize(p.join(path, appname))}');
          if (first) {
            break;
          }
        }
      }
    } finally {
      forEach.close();
    }

    return forEach;
  }
}
