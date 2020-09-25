import 'package:path/path.dart' as p;
import '../../dcli.dart';
import '../util/progress.dart';

import 'dcli_function.dart';
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
/// If the [verbose] flag is true then a line is output to
/// the [progress] for each path searched.
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
/// To print the path to the command:
///
/// ```dart
/// print(which('ls').path);
/// ```
///
/// To check if an app is on the path use:
///
/// ```dart
/// if (which('apt').found)
/// {
///   print('found apt');
/// }
/// ```
///
Which which(String appname,
        {bool first = true, bool verbose = false, Progress progress}) =>
    _Which().which(appname, first: first, verbose: verbose, progress: progress);

class Which {
  String _path;
  final _paths = <String>[];
  bool _found = false;

  /// The progress used to accumualte the results
  /// If [verbose] was passed this will contain all
  /// of the verbose output. If you passed a [progress]
  /// into the which call then this will be the same progress
  /// otherwse a Progress.devNull will be allocated and returned.
  Progress progress;

  /// The first path found containing [appname]
  ///
  /// See [paths] for a list of all paths that contained [appnam]
  String get path => _path;

  /// Contains the list of paths that contain [appname].
  ///
  /// If no paths are found then this list will be empty.
  ///
  /// If [first] is true this will contain at most 1 path.
  List<String> get paths => _paths;

  /// Returns true if at least one path was found that contained [appname]
  bool get found => _found;

  /// Returns true if [appname] was not found in any path.
  bool get notfound => !_found;
}

class _Which extends DCliFunction {
  ///
  /// Searches the path for the given appname.
  Which which(String appname, {bool first, bool verbose, Progress progress}) {
    var results = Which();
    try {
      progress ??= Progress.devNull();
      results.progress = progress;

      for (var path in PATH) {
        if (verbose) {
          progress.addToStdout('Searching: ${truepath(path)}');
        }
        if (exists(p.join(path, appname))) {
          var fullpath = truepath(p.join(path, appname));
          progress.addToStdout(fullpath);
          results._path ??= fullpath;
          results.paths.add(fullpath);
          results._found = true;
          if (first) {
            break;
          }
        }
      }
    } finally {
      progress.close();
    }

    return results;
  }
}
