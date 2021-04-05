import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import '../../dcli.dart';

import 'dcli_exception.dart';
import 'runnable_process.dart';
import 'stack_trace_impl.dart';
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
  ///
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
  static String tempFile({String? suffix}) {
    var finalsuffix = suffix ?? 'tmp';

    if (!finalsuffix.startsWith('.')) {
      finalsuffix = '.$finalsuffix';
    }
    const uuid = Uuid();
    return '${join(Directory.systemTemp.path, uuid.v4())}$finalsuffix';
  }

  /// The path to this file.
  String get path => _file.path;

  void _open(FileMode fileMode) {
    _raf = _file.openSync(mode: fileMode);
  }

  /// Reads a single line from the file.
  /// [lineDelimiter] the end of line delimiter.
  /// May be one or two characters long.
  /// Defaults to \n.
  ///
  String? readLine({String lineDelimiter = '\n'}) {
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
  int get length => _file.lengthSync();

  /// Close and flushes a file to disk.
  void close() {
    _raf.closeSync();
  }

  /// reads every line from a file calling the passed [lineAction]
  /// for each line.
  /// if you return false from a [lineAction] call then
  /// the read returns and no more lines are read.
  void read(CancelableLineAction lineAction) {
    final inputStream = _file.openRead();

    final stackTrace = StackTraceImpl();

    Object? exception;

    final done = Completer<bool>();

    late StreamSubscription<String> subscription;

    subscription =
        utf8.decoder.bind(inputStream).transform(const LineSplitter()).listen(
            (line) {
              final cont = lineAction(line);
              if (cont == false) {
                subscription.cancel().then((finished) => done.complete(true));
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
            });

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
  /// If [newline] is null then no line terminator will
  /// be added.
  void write(String line, {String? newline = '\n'}) {
    final finalline = line + (newline ?? '');
    _raf
      ..truncateSync(0)
      ..setPositionSync(0)
      ..flushSync()
      ..writeStringSync(finalline);
  }

  /// Appends the [line] to the file
  /// If [newline] is true then append a newline after the line.
  void append(String line, {String? newline = '\n'}) {
    final finalline = line + (newline ?? '');

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
void symlink(
  String existingPath,
  String linkPath,
) {
  Settings().verbose('symlink existingPath: $existingPath linkPath $linkPath');
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
  Settings().verbose('deleteSymlink linkPath: $linkPath');
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

  Settings().verbose('resolveSymLink $pathToLink resolved: $resolved');
  return resolved;
}

///
/// Returns a FileStat instance describing the
/// file or directory located by [path].
///
FileStat stat(String path) => File(path).statSync();
