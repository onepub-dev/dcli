/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart' show CopyException, symlink;

import '../util/wait_for_ex.dart';
export 'package:dcli_core/dcli_core.dart' show CopyException;

///
/// Copies the file [from] to the path [to].
///
/// ```dart
/// copy("/tmp/fred.text", "/tmp/fred2.text", overwrite=true);
/// ```
///
/// [to] may be a directory in which case the [from] filename is
/// used to construct the [to] files full path.
///
/// If [to] is a file then the  file must not exist unless [overwrite]
///  is set to true.
///
/// If [to] is a directory then the directory must exist.
///
/// If [from] is a symlink we copy the file it links to rather than
/// the symlink. This mimics the behaviour of gnu 'cp' command.
///
/// If you need to copy the actualy symlink see [symlink].
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyException] is thrown.
void copy(String from, String to, {bool overwrite = false}) =>
    // ignore: discarded_futures
    waitForEx(core.copy(from, to, overwrite: overwrite));
