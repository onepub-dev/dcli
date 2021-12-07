import 'dart:io';

import '../../dcli_core.dart';
import '../util/logging.dart';

///
/// Deletes the file at [path].
///
/// If the file does not exists a DeleteException is thrown.
///
/// ```dart
/// delete("/tmp/test.fred", ask: true);
/// ```
///
/// If the [path] is a directory a DeleteException is thrown.
Future<void> delete(String path) async => _Delete().delete(path);

class _Delete extends DCliFunction {
  Future<void> delete(String path) async {
    verbose(() => 'delete:  ${truepath(path)}');

    if (!exists(path)) {
      throw DeleteException('The path ${truepath(path)} does not exists.');
    }

    if (isDirectory(path)) {
      throw DeleteException('The path ${truepath(path)} is a directory.');
    }

    try {
      await File(path).delete();
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw DeleteException(
        'An error occured deleting ${truepath(path)}. Error: $e',
      );
    }
  }
}

/// Thrown when the [delete] function encounters an error
class DeleteException extends DCliFunctionException {
  /// Thrown when the [delete] function encounters an error
  DeleteException(String reason) : super(reason);
}
