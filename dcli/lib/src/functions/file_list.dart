/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

///
/// returns the list of files and directories
/// in the current directory.
///
/// See:
///  * [find] for more advanced options when obtain a file list.
List<String> get fileList => _FileList().fileList;

class _FileList extends core.DCliFunction {
  List<String> get fileList {
    final files = <String>[];

    verbose(() => 'fileList pwd: ${truepath(pwd)}');

    Directory.current.listSync().forEach((file) => files.add(file.path));
    return files;
  }
}
