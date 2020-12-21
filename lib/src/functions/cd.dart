import 'dart:io';

import 'package:path/path.dart' as p;
import '../settings.dart';
import 'function.dart';

import 'is.dart';

/// Change Directories to the relative or absolute path.
///
/// If [path] does not exists an exception is thrown
///
/// ```dart
/// cd("/tmp");
/// ```
///
/// NOTE: changing the directory changes the directory
/// for all isolates.
///
/// Using push/pop/cd is considered bad form.
///
/// Instead use absolute or relative paths.
///
/// See push
///     [pop]
///     [pwd]
///     [join]
///
///     use join in prefrence to cd/push/pop
@Deprecated('Use join')
void cd(String path) => CD().cd(path);

/// Class that implements the [cd] function.
@Deprecated('Use join')
class CD extends DCliFunction {
  /// implements the [cd] (change dir) function.
  void cd(String path) {
    Settings().verbose('cd $path -> ${p.canonicalize(path)}');

    if (!exists(path)) {
      throw CDException('The path ${p.canonicalize(path)} does not exists.');
    }
    Directory.current = p.join(Directory.current.path, path);
  }
}

/// ignore: deprecated_member_use_from_same_package
/// Throw when the [cd] function encounters an error.
class CDException extends FunctionException {
  /// ignore: deprecated_member_use_from_same_package
  /// Throw when the [cd] function encounters an error.
  CDException(String reason) : super(reason);
}
