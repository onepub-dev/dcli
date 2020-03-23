import 'package:path/path.dart';

import '../../dshell.dart';
import 'function.dart';
import '../settings.dart';

import 'is.dart';

///
/// Copies the contents of the [from] directory to the
/// to the [to] path.
///
/// The [to] path must exist.
///
/// If any copied file already exists in the [to] path then
/// an exeption is throw and a parital copyDir may occured.
///
/// You can force the copyDir to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
///
/// ```dart
/// copyDir("/tmp/", "/tmp/new_dir", overwrite=true);
/// ```
/// By default hidden files are ignored. To allow hidden files to
/// be passed set [includeHidden] to true.
///
/// You can select which files are to be copied by passing a [filter].
/// If a [filter] isn't passed then all files are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// copyDir("/tmp/", "/tmp/new_dir", overwrite=true
///   , filter: (file) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we copy a file.
///
/// ```dart
/// copyDir("/tmp/", "/tmp/new_dir", overwrite=true
///   , filter: (file) {
///   var include = extension(file) == 'dart';
///   if (include) {
///     print('copying: $file');
///   }
///   return include;
/// });
/// ```
///
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyDirException] is thrown.
void copyDir(String from, String to,
        {bool overwrite = false,
        bool includeHidden = false,
        bool recursive = false,
        bool Function(String file) filter}) =>
    CopyDir().copyDir(from, to,
        overwrite: overwrite,
        includeHidden: includeHidden,
        filter: filter,
        recursive: recursive);

class CopyDir extends DShellFunction {
  void copyDir(String from, String to,
      {bool overwrite = false,
      bool Function(String file) filter,
      bool includeHidden,
      bool recursive}) {
    if (!isDirectory(from)) {
      throw CopyDirException(
          'The [from] path ${truepath(from)} must be a directory.');
    }
    if (!exists(to)) {
      throw CopyDirException(
          'The [to] path ${truepath(to)} must already exist.');
    }

    if (!isDirectory(to)) {
      throw CopyDirException(
          'The [to] path ${truepath(to)} must be a directory.');
    }

    Settings().verbose('copyDir called ${truepath(from)} -> ${truepath(to)}');

    try {
      find('*', root: from, includeHidden: includeHidden, recursive: recursive)
          .forEach((file) {
        var include = true;
        if (filter != null) include = filter(file);
        if (include) {
          var target = join(to, relative(file, from: from));

          if (recursive && !exists(dirname(target))) {
            createDir(dirname(target), recursive: true);
          }

          if (!overwrite && exists(target)) {
            throw CopyDirException(
                'The target file ${truepath(target)} already exists.');
          }

          copy(file, target, overwrite: overwrite);
          Settings().verbose(
              'copyDir copying: ${truepath(from)} -> ${truepath(target)}');
        }
      });
    } catch (e) {
      throw CopyDirException(
          'An error occured copying directory ${truepath(from)} to ${truepath(to)}. Error: $e');
    }
  }
}

class CopyDirException extends FunctionException {
  CopyDirException(String reason) : super(reason);
}
