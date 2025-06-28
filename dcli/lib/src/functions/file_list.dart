/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
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
