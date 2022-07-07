/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart' show TouchException;

import '../util/wait_for_ex.dart';

/// Updates the last modified time stamp of a file.
///
/// ```dart
/// touch('fred.txt');
/// touch('fred.txt, create: true');
/// ```
///
///
/// If [create] is true and the file doesn't exist
/// it will be created.
///
/// If [create] is false and the file doesn't exist
/// a [TouchException] will be thrown.
///
/// [create] is false by default.
///
/// As a convenience the touch function returns the [path] variable
/// that was passed in.
String touch(String path, {bool create = false}) =>
    waitForEx(core.touch(path, create: create));
