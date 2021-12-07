import 'dart:io';

import 'package:path/path.dart';

import '../../dcli_core.dart';

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
/// [appname] in the order they were found.
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
/// command search. For example the dart  will be 'dart'
/// on Linux and 'dart.bat' on Windows. Using `which('dart')` will find `dart`
///  on linux and `dart.bat` on Windows.
Future<Which> which(
  String appname, {
  bool first = true,
  bool verbose = false,
  bool extensionSearch = true,
  Sink<WhichSearch>? progress,
}) async =>
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
  Stream<String>? progress;

  /// The first path found containing appname
  ///
  /// See [paths] for a list of all paths that contained appname
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

/// Search resutls from the [which] method.
class WhichSearch {
  /// the app was found on the path.
  WhichSearch.found(this.path, this.exePath) : found = true;

  /// the app was not found.
  WhichSearch.notfound(this.path) : found = false;

  /// passed in path to search for.
  String path;

  /// true if the app was found
  bool found;

  /// If the app was found this is the fully qualified path to the app.
  String? exePath;
}

class _Which extends DCliFunction {
  ///
  /// Searches the path for the given appname.
  Future<Which> which(
    String appname, {
    required bool extensionSearch,
    bool first = true,
    bool verbose = false,
    Sink<WhichSearch>? progress,
  }) async {
    final results = Which();
    try {
      for (final path in PATH) {
        final fullpath =
            await _appExists(path, appname, extensionSearch: extensionSearch);
        if (fullpath == null) {
          progress?.add(WhichSearch.notfound(path));
        } else {
          progress?.add(WhichSearch.found(path, fullpath));

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
  Future<String?> _appExists(
    String pathTo,
    String appname, {
    required bool extensionSearch,
  }) async {
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
