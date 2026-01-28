/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:path/path.dart';

import '../functions/env.dart';
import '../functions/pwd.dart';

/// [truepath] creates an absolute and normalized path.
///
/// True path provides a safe and consistent manner for
/// manipulating, accessing and displaying paths.
///
/// Works like [join] in that it concatenates a set of directories
/// into a path.
/// [truepath] then goes on to create an absolute path which
/// is then normalize to remove any segments (.. or .).
///
/// @Throwing(ArgumentError)
String truepath(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
]) =>
    normalize(absolute(join(part1, part2, part3, part4, part5, part6, part7)));

/// Removes the users home directory from a path replacing it with ~
/// @Throwing(ArgumentError)
String privatePath(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
]) {
  final prefix = rootPrefix(HOME);
  var tp = truepath(part1, part2, part3, part4, part5, part6, part7);
  if (HOME != '.') {
    tp = tp.replaceAll(HOME, '$prefix<HOME>');
  }
  return tp;
}

/// Returns the root path of your file system.
///
/// On Linux and MacOS this will be `/`
///
/// On Windows this will be `'C:\`
///
/// The drive letter will depend on the
/// drive of your present working directory (pwd).
String get rootPath => rootPrefix(pwd);
