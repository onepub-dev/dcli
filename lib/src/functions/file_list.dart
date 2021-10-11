import 'dart:io';

import '../settings.dart';
import '../util/truepath.dart';
import 'find.dart';
import 'function.dart';
import 'pwd.dart';

///
/// returns the list of files and directories
/// in the current directory.
///
/// See:
///  * [find] for more advanced options when obtain a file list.
List<String> get fileList => _FileList().fileList;

class _FileList extends DCliFunction {
  List<String> get fileList {
    final files = <String>[];

    verbose(() => 'fileList pwd: ${truepath(pwd)}');

    Directory.current.listSync().forEach((file) => files.add(file.path));
    return files;
  }
}
