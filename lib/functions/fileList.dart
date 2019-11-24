import 'dart:io';

import 'package:dshell/functions/function.dart';

import '../util/log.dart';

import 'pwd.dart';
import 'settings.dart';

///
/// returns the list of files and directories
/// in the current directory.
///
/// See [find] for more advanced options when obtain a file list.
List<String> get fileList => FileList().fileList;

class FileList extends DShellFunction {
  List<String> get fileList {
    List<String> files = List();

    if (Settings().debug_on) {
      Log.d("fileList pwd: ${absolute(pwd)}");
    }

    Directory.current.listSync().forEach((file) => files.add(file.path));
    return files;
  }
}
