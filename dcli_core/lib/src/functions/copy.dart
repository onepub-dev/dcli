import 'dart:io';

import 'package:path/path.dart';

import '../../dcli_core.dart';
import '../util/logging.dart';

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
/// The [to] file must not exists unless [overwrite] is set to true.
///
/// If [from] is a symlink we copy the file it links to rather than
/// the symlink. This mimics the behaviour of gnu 'cp' command.
///
/// If you need to copy the actualy symlink see [symlink].
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyException] is thrown.
Future<void> copy(String from, String to, {bool overwrite = false}) async =>
    _Copy().copy(from, to, overwrite: overwrite);

class _Copy extends DCliFunction {
  Future<void> copy(String from, String to, {bool overwrite = false}) async {
    var finalto = to;
    if (isDirectory(finalto)) {
      finalto = join(finalto, basename(from));
    }
    verbose(() =>
        'copy ${truepath(from)} -> ${truepath(finalto)} overwrite: $overwrite');

    if (overwrite == false && exists(finalto, followLinks: false)) {
      throw CopyException(
        'The target file ${truepath(finalto)} already exists.',
      );
    }

    try {
      /// if we are copying a symlink then we copy the file rather than
      /// the symlink as this mimicks gnu 'cp'.
      if (isLink(from)) {
        final resolvedFrom = await resolveSymLink(from);
        await File(resolvedFrom).copy(finalto);
      } else {
        await File(from).copy(finalto);
      }
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      /// lets try and improve the message.
      /// We do these checks only on failure
      /// so in the most common case (everything is correct)
      /// we don't waste cycles on unnecessary work.
      if (!exists(from)) {
        throw CopyException(
            "The 'from' file ${truepath(from)} does not exists.");
      }
      if (!exists(dirname(to))) {
        throw CopyException(
          "The 'to' directory ${truepath(dirname(to))} does not exists.",
        );
      }

      throw CopyException(
        'An error occured copying ${truepath(from)} to ${truepath(finalto)}. '
        'Error: $e',
      );
    }
  }
}

/// Throw when the [copy] function encounters an error.
class CopyException extends DCliFunctionException {
  /// Throw when the [copy] function encounters an error.
  CopyException(String reason) : super(reason);
}
