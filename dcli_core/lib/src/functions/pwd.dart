/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'dcli_function.dart';

///
/// Returns the current working directory.
///
/// ```dart
/// print(pwd);
/// ```
///
/// See join
///
String get pwd => _PWD().pwd;

class _PWD extends DCliFunction {
  String get pwd => Directory.current.path;
}
