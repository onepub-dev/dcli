import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import 'temp_file.dart';
import 'wait_for_ex.dart';

///
/// Provides a set of methods to read/write
/// a file synchronisly.
///
/// The class is mostly used internally.
///
/// Note: the api to this class is considered EXPERIMENTAL
/// and is subject to change.
class FileSync {
  /// If you instantiate FileSync you MUST call [close].
  ///
  /// We rececommend that you use [withOpenFile] in prefernce to directly
  /// calling this method.
  FileSync(String path, {FileMode fileMode = FileMode.writeOnlyAppend}) {
    _file = File(path);
    _open(fileMode);
  }

  late File _file;
  late RandomAccessFile _raf;

  /// Generates a temporary filename in the system temp directory
  /// that is guaranteed to be unique.
  ///
  /// This method does not create the file.
  ///
  /// The temp file name will be <uuid>.tmp
  /// unless you provide a [suffix] in which
  /// case the file name will be <uuid>.<suffix>
  @Deprecated('Use createTempFilename')
  static String tempFile({String? suffix}) =>
      createTempFilename(suffix: suffix);

  /// The path to this file.
  String get path => _file.path;

  void _open(FileMode fileMode) {
    _raf = _file.openSync(mode: fileMode);
  }

  /// Reads a single line from the file.
  /// [lineDelimiter] the end of line delimiter.
  /// May be one or two characters long.
  /// Defaults to the platform specific delimiter as
  /// defined by  [Platform().eol].
  ///
  String? readLine({String? lineDelimiter}) {
    lineDelimiter ??= Platform().eol;
    final line = StringBuffer();
    int byte;
    var priorChar = '';

    var foundDelimiter = false;

    while ((byte = _raf.readByteSync()) != -1) {
      final char = utf8.decode([byte]);

      if (_isLineDelimiter(priorChar, char, lineDelimiter)) {
        foundDelimiter = true;
        break;
      }

      line.write(char);
      priorChar = char;
    }
    final endOfFile = line.isEmpty && foundDelimiter == false;
    return endOfFile ? null : line.toString();
  }

  ///
  /// Flushes the contents of the file to disk.
  void flush() {
    _raf.flushSync();
  }

  /// Returns the length of the file in bytes
  /// The file does NOT have to be open
  /// to determine its length.
  /// See:
  ///  * [fileLength]
  int get length => _file.lengthSync();

  /// Close and flushes the file to disk.
  void close() {
    _raf.closeSync();
  }

  /// reads every line from a file calling the passed [lineAction]
  /// for each line.
  /// if you return false from a [lineAction] call then
  /// the read returns and no more lines are read.
  void read(CancelableLineAction lineAction) {
    final inputStream = _file.openRead();

    final stackTrace = core.StackTraceImpl();

    Object? exception;

    final done = Completer<bool>();

    late StreamSubscription<String> subscription;

    subscription =
        utf8.decoder.bind(inputStream).transform(const LineSplitter()).listen(
              (line) async {
                final cont = await lineAction(line);
                if (cont == false) {
                  await subscription
                      .cancel()
                      .then((finished) => done.complete(true));
                }
              },
              cancelOnError: true,
              //ignore: avoid_types_on_closure_parameters
              onError: (Object error) {
                exception = error;
                done.complete(false);
              },
              onDone: () {
                done.complete(true);
              },
            );

    waitForEx(done.future);

    if (exception != null) {
      if (exception is DCliException) {
        // not an exception, the user just doesn't want to continue.
      } else {
        throw DCliException.from(exception, stackTrace);
      }
    }
  }

  /// This is just a wrapper for the method File.resolveSymbolicLinksSync.
  /// Returns the path the symbolic link links to.
  String resolveSymLink() => _file.resolveSymbolicLinksSync();

  /// Truncates the file to zero bytes and
  /// then writes the given text to the file.
  /// If [newline] is null or isn't passed then the platform
  /// end of line characters are appended as defined by
  /// [Platform().eol].
  /// Pass null or an '' to [newline] to not add a line terminator.
  void write(String line, {String? newline}) {
    final finalline = line + (newline ?? Platform().eol);
    _raf
      ..truncateSync(0)
      ..setPositionSync(0)
      ..flushSync()
      ..writeStringSync(finalline);
  }

  /// Exposed the RandomFileAccess method writeFromSync.
  ///
  /// Synchronously writes from a [buffer] to the file
  /// at the current seek position and increments the seek position
  /// by the no. of bytes written.
  /// Will read the buffer from index [start] to index [end].
  /// The [start] must be non-negative and no greater than [buffer].length.
  /// If [end] is omitted, it defaults to [buffer].length.
  /// Otherwise [end] must be no less than [start] and no
  /// greater than [buffer].length.
  /// Throws a [FileSystemException] if the operation fails.
  void writeFromSync(List<int> buffer, [int start = 0, int? end]) {
    _raf.writeFromSync(buffer, start, end);
  }

  /// Exposed the RandomFileAccess method readIntoSync
  /// Synchronously reads into an existing [buffer].
  ///
  /// Reads bytes and writes then into the the range of [buffer] from [start]
  /// to [end].
  /// The [start] must be non-negative and no greater than [buffer].length.
  /// If [end] is omitted, it defaults to [buffer].length.
  /// Otherwise [end] must be no less than [start] and no greater
  ///  than [buffer].length.
  ///
  /// Returns the number of bytes read. This maybe be less than end - start
  ///  if the file doesn't have that many bytes to read.
  ///
  /// Throws a [FileSystemException] if the operation fails.
  int readIntoSync(List<int> buffer, [int start = 0, int? end]) =>
      _raf.readIntoSync(buffer, start, end);

  /// Appends the [line] to the file
  /// Appends [newline] after the line.
  /// If [newline] is null or isn't passed then the platform
  /// end of line characters are appended as defined by
  /// [Platform().eol].
  /// Pass null or an '' to [newline] to not add a line terminator.
  void append(String line, {String? newline}) {
    final finalline = line + (newline ?? Platform().eol);

    _raf
      ..setPositionSync(_raf.lengthSync())
      ..writeStringSync(finalline);
  }

  /// Truncates the file to zero bytes in length.
  void truncate() {
    _raf.truncateSync(0);
  }

  bool _isLineDelimiter(String priorChar, String char, String lineDelimiter) {
    if (lineDelimiter.length == 1) {
      return char == lineDelimiter;
    } else {
      return priorChar + char == lineDelimiter;
    }
  }
}

/// Opens a File and calls [action] passing in the open file.
/// When action completes the file is closed.
/// Use this method in preference to directly callling [FileSync()]
R withOpenFile<R>(
  String pathToFile,
  R Function(FileSync) action, {
  FileMode fileMode = FileMode.writeOnlyAppend,
}) {
  final file = FileSync(pathToFile, fileMode: fileMode);

  R result;
  try {
    result = action(file);
  } finally {
    file.close();
  }
  return result;
}

///
/// Creates a link at [linkPath] which points to an
/// existing file or directory at [existingPath]
///
/// On Windows you need to be in developer mode or running as an Administrator
/// to create a symlink.
///
/// To enable developer mode see:
/// https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows
///
/// To check if your script is running as an administrator use:
///
/// [Shell.current.isPrivileged]
///
/// See:
///  * [deleteSymlink]
///  * [resolveSymLink]
void symlink(
  String existingPath,
  String linkPath,
) {
  verbose(() => 'symlink existingPath: $existingPath linkPath $linkPath');
  Link(linkPath).createSync(existingPath);
}

///
/// Deletes the symlink at [linkPath]
///
/// On Windows you need to be in developer mode or running as an Administrator
/// to delete a symlink.
///
/// To enable developer mode see:
/// https://bsutton.gitbook.io/dcli/getting-started/installing-on-windows
///
/// To check if your script is running as an administrator use:
///
/// [Shell.current.isPrivileged]
///
void deleteSymlink(String linkPath) {
  verbose(() => 'deleteSymlink linkPath: $linkPath');
  Link(linkPath).deleteSync();
}

///
/// Resolves the a symbolic link [pathToLink]
/// to the ultimate target path.
///
/// The return path will be canonicalized.
///
/// e.g.
/// ```dart
/// resolveSymLink('/usr/bin/dart) == '/usr/lib/bin/dart'
/// ```
///
/// throws a FileSystemException if the target path does not exist.
String resolveSymLink(String pathToLink) {
  final normalised = canonicalize(pathToLink);

  String resolved;
  if (isDirectory(normalised)) {
    resolved = Directory(normalised).resolveSymbolicLinksSync();
  } else {
    resolved = canonicalize(File(normalised).resolveSymbolicLinksSync());
  }

  verbose(() => 'resolveSymLink $pathToLink resolved: $resolved');
  return resolved;
}
