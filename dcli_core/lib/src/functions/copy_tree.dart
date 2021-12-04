import 'dart:async';

import 'package:path/path.dart';

import '../../dcli_core.dart';
import '../util/logging.dart';

///
/// Copies the contents of the [from] directory to the
/// [to] path with an optional filter.
///
/// The [to] path must exist.
///
/// If any copied file already exists in the [to] path then
/// an exeption is throw and a parital copyTree may occur.
///
/// You can force the copyTree to overwrite files in the [to]
/// directory by setting [overwrite] to true (defaults to false).
///
/// The [recursive] argument controls whether subdirectories are
/// copied. If [recursive] is true (the default) it will copy
/// subdirectories.
///
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true);
/// ```
/// By default hidden files are ignored. To allow hidden files to
/// be processed set [includeHidden] to true.
///
/// You can select which files are to be copied by passing a [filter].
/// If a [filter] isn't passed then all files are copied as per
/// the [includeHidden] state.
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true, includeHidden:true
///   , filter: (file) => extension(file) == 'dart');
/// ```
///
/// The [filter] method can also be used to report progress as it
/// is called just before we copy a file.
///
/// ```dart
/// copyTree("/tmp/", "/tmp/new_dir", overwrite:true
///   , filter: (file) {
///   var include = extension(file) == 'dart';
///   if (include) {
///     print('copying: $file');
///   }
///   return include;
/// });
/// ```
///
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyTreeException] is thrown.
Future<void> copyTree(
  String from,
  String to, {
  bool overwrite = false,
  bool includeHidden = false,
  bool recursive = true,
  bool Function(String file) filter = _allowAll,
}) async =>
    _CopyTree().copyTree(
      from,
      to,
      overwrite: overwrite,
      includeHidden: includeHidden,
      filter: filter,
      recursive: recursive,
    );

bool _allowAll(String file) => true;

class _CopyTree extends DCliFunction {
  Future<void> copyTree(
    String from,
    String to, {
    bool overwrite = false,
    bool Function(String file) filter = _allowAll,
    bool includeHidden = false,
    bool recursive = true,
  }) async {
    if (!isDirectory(from)) {
      throw CopyTreeException(
        'The [from] path ${truepath(from)} must be a directory.',
      );
    }
    if (!exists(to)) {
      throw CopyTreeException(
        'The [to] path ${truepath(to)} must already exist.',
      );
    }

    if (!isDirectory(to)) {
      throw CopyTreeException(
        'The [to] path ${truepath(to)} must be a directory.',
      );
    }

    final controller = StreamController<FindItem>();
    late final StreamSubscription<FindItem> sub;
    sub = controller.stream.listen((item) async => _process(
        item.pathTo, filter, from, to,
        overwrite: overwrite, recursive: recursive));
    try {
      sub.pause();
      await find('*',
          workingDirectory: from,
          includeHidden: includeHidden,
          recursive: recursive,
          progress: controller);
      verbose(
        () => 'copyTree copied: ${truepath(from)} -> ${truepath(to)}, '
            'includeHidden: $includeHidden, recursive: $recursive, '
            'overwrite: $overwrite',
      );
      sub.resume();
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw CopyTreeException(
        'An error occured copying directory'
        ' ${truepath(from)} to ${truepath(to)}. '
        'Error: $e',
      );
    }
    await controller.close();
    await sub.cancel();
  }

  Future<void> _process(
      String file, bool Function(String file) filter, String from, String to,
      {required bool overwrite, required bool recursive}) async {
    if (filter(file)) {
      final target = join(to, relative(file, from: from));

      if (recursive && !exists(dirname(target))) {
        await createDir(dirname(target), recursive: true);
      }

      if (!overwrite && exists(target)) {
        throw CopyTreeException(
          'The target file ${truepath(target)} already exists.',
        );
      }

      await copy(file, target, overwrite: overwrite);
    }
  }
}

/// Throw when the [copy] function encounters an error.
class CopyTreeException extends DCliFunctionException {
  /// Throw when the [copy] function encounters an error.
  CopyTreeException(String reason) : super(reason);
}
