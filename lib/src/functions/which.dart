import 'dart:async';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart';

import '../util/progress.dart';
import '../util/wait_for_ex.dart';

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
core.Which which(
  String appname, {
  bool first = true,
  bool verbose = false,
  bool extensionSearch = true,
  Sink<String>? progress,
}) {
  core.Which which;
  final controller = StreamController<WhichSearch>();

  try {
    controller.stream.listen((whichSearch) {
      if (verbose) {
        progress?.add('Searching: ${truepath(whichSearch.path)}');
      }
      if (whichSearch.found) {
        progress?.add(whichSearch.exePath!);
      }
    });

    which = waitForEx(
      core.which(
        appname,
        first: first,
        verbose: verbose,
        extensionSearch: extensionSearch,
        progress: controller.sink,
      ),
    );
  } finally {
    // controller.close();
  }
  return which;
}
