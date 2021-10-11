import 'dart:io';

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
/// if [extensionSearch] is true and the passed [appname]  doesn't have a file
/// extension then when running on Windows the which  command will search
/// for [appname] plus [appname] with each of the extensions listed
/// in the Windows environment variable PATHEX.
/// This feature is intended to make it easier to implement cross platform
/// command search. In particular dart commands such as 'pub' will be 'pub'
/// on Linux and 'pub.bat' on Windows. Using `which('pub')` will find `pub` on
/// linux and `pub.bat` on Windows.
Which which(
  String appname, {
  bool first = true,
  bool verbose = false,
  bool extensionSearch = true,
  Progress? progress,
}) =>
    _Which().which(
      appname,
      first: first,
      verbose: verbose,
      extensionSearch: extensionSearch,
      progress: progress,
    );

/// Returned from the [which] funtion to provide the details we discovered
/// about  appname.
class Which {
  String? _path;
  final _paths = <String>[];
  bool _found = false;

  /// The progress used to accumualte the results
  /// If verbose was passed this will contain all
  /// of the verbose output. If you passed a [progress]
  /// into the which call then this will be the same progress
  /// otherwse a Progress.devNull will be allocated and returned.
  Progress? progress;

  /// The first path found containing appname
  ///
  /// See:
  ///  * [paths] for a list of all paths that contained appname
  String? get path => _path;

  /// Contains the list of paths that contain appname.
  ///
  /// If no paths are found then this list will be empty.
  ///
  /// If first is true this will contain at most 1 path.
  List<String> get paths => _paths;

  /// Returns true if at least one path was found that contained appname
  bool get found => _found;

  /// Returns true if appname was not found in any path.
  bool get notfound => !_found;
}

class _Which extends DCliFunction {
  ///
  /// Searches the path for the given appname.
  Which which(
    String appname, {
    required bool extensionSearch,
    bool first = true,
    bool verbose = false,
    Progress? progress,
  }) {
    final results = Which();
    try {
      progress ??= Progress.devNull();
      results.progress = progress;

      for (final path in PATH) {
        if (verbose) {
          progress.addToStdout('Searching: ${truepath(path)}');
        }
        final fullpath =
            _appExists(path, appname, extensionSearch: extensionSearch);
        if (fullpath != null) {
          progress.addToStdout(fullpath);
          if (!results._found) {
            results._path = fullpath;
          }
          results.paths.add(fullpath);
          results._found = true;
          if (first) {
            break;
          }
        }
      }
    } finally {
      progress!.close();
    }

    return results;
  }

  /// Checks if [appname] exists in [pathTo].
  ///
  /// On Windows if [extensionSearch] is true and [appname] doesn't
  /// have an extension then we check each appname.extension variant
  /// to see if it exists. We first check if just an file of [appname] with
  /// no extension exits.
  String? _appExists(
    String pathTo,
    String appname, {
    required bool extensionSearch,
  }) {
    final pathToAppname = join(pathTo, appname);
    if (exists(pathToAppname)) {
      return pathToAppname;
    }
    if (Platform.isWindows && extensionSearch && extension(appname).isEmpty) {
      final pathExt = env['PATHEXT'];

      if (pathExt != null) {
        final extensions = pathExt.split(';');
        for (final extension in extensions) {
          final fullname = '$pathToAppname$extension';
          if (exists(fullname)) {
            return fullname;
          }
        }
      }
    }
    return null;
  }
}
