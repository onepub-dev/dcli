import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart' show DeleteDirException;

import '../../dcli.dart';

export 'package:dcli_core/dcli_core.dart' show DeleteDirException;

///
/// Deletes the directory located at [path].
///
/// If [recursive] is true (default true) then the directory and all child files
/// and directories will be deleted.
///
/// ```dart
/// deleteDir("/tmp/testing", recursive=true);
/// ```
///
/// If [path] is not a directory then a [DeleteDirException] is thrown.
///
/// If the directory does not exists a [DeleteDirException] is thrown.
///
/// If the directory cannot be delete (e.g. permissions) a
/// [DeleteDirException] is thrown.
///
/// If recursive is false the directory must be empty otherwise a
/// [DeleteDirException] is thrown.
///
/// See:
///  * [isDirectory]
///  * [exists]
///
void deleteDir(String path, {bool recursive = true}) =>
    waitForEx(core.deleteDir(path, recursive: recursive));
