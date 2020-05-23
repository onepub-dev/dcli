import 'dart:io';

import '../settings.dart';
import 'function.dart';

import 'pwd.dart';

///
/// returns the list of files and directories
/// in the current directory.
///
/// See [_find] for more advanced options when obtain a file list.
List<String> get fileList => _FileList().fileList;

class _FileList extends DShellFunction {
  List<String> get fileList {
    var files = <String>[];

    Settings().verbose('fileList pwd: ${absolute(pwd)}');

    Directory.current.listSync().forEach((file) => files.add(file.path));
    return files;
  }
}
