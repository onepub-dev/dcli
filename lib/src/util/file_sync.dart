import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/dshell.dart';

import 'waitForEx.dart';

import 'dshell_exception.dart';
import 'log.dart';
import 'runnable_process.dart';
import 'stack_trace_impl.dart';

class FileSync {
  File _file;
  RandomAccessFile _raf;

  FileSync(String path, {FileMode fileMode = FileMode.writeOnlyAppend}) {
    _file = File(path);
    _open(fileMode);
  }

  String get path => _file.path;

  void _open(FileMode fileMode) {
    _raf = _file.openSync(mode: fileMode);
  }

  String readLine({String lineDelimiter = '\n'}) {
    var line = '';
    int byte;
    var priorChar = '';

    var foundDelimiter = false;

    while ((byte = _raf.readByteSync()) != -1) {
      var char = utf8.decode([byte]);

      if (isLineDelimiter(priorChar, char, lineDelimiter)) {
        foundDelimiter = true;
        break;
      }

      line += char;
      priorChar = char;
    }
    if (line.isEmpty && foundDelimiter == false) {
      line = null;
    }
    return line;
  }

  ///
  /// Flushes the contents of the file to disk.
  void flush() {
    _raf.flushSync();
  }

  /// Returns the length of the file in bytes
  /// The file does NOT have to be open
  /// to determine its length.
  int get length {
    return _file.lengthSync();
  }

  // close and flushes a file.
  void close() {
    _raf.closeSync();
  }

  /// reads every line from a file calling the passed [lineAction]
  /// for each line.
  /// if you return [false] from a [lineAction] call then
  /// the read returns and no more lines are read.
  void read(CancelableLineAction lineAction) {
    var inputStream = _file.openRead();

    var stackTrace = StackTraceImpl();

    Object exception;

    var done = Completer<bool>();
    // bool stop = false;

    try {
      StreamSubscription<String> subscription;

      subscription =
          utf8.decoder.bind(inputStream).transform(const LineSplitter()).listen(
              (line) {
                if (lineAction != null) {
                  var cont = lineAction(line);
                  if (cont == false) {
                    subscription
                        .cancel()
                        .then((dynamic finished) => done.complete(true));
                  }
                }
              },
              cancelOnError: true,
              onError: (Object error) {
                exception = error;
                done.complete(false);
              },
              onDone: () {
                done.complete(true);
              });
    } catch (e) {
      Log.e('exception $e');
    }

    waitForEx(done.future);

    if (exception != null) {
      if (exception is DShellException) {
        // not an exception, the user just doesn't want to continue.
      } else {
        throw DShellException.from(exception, stackTrace);
      }
    }
  }

  FileStat stat() {
    return _file.statSync();
  }

  String resolveSymLink() {
    return _file.resolveSymbolicLinksSync();
  }

  /// Truncates the file to zero bytes and
  /// then writes the given text to the file.
  /// If [newline] is null then no line terminator will
  /// be added.
  void write(String line, {String newline = '\n'}) {
    line += (newline ?? '');
    _raf.truncateSync(0);

    _raf.setPositionSync(0);
    _raf.flushSync();

    _raf.writeStringSync(line);
  }

  /// Appends the [line] to the file
  /// If [newLine] is true then append a newline after the line.
  void append(String line, {String newline = '\n'}) {
    line += (newline ?? '');

    _raf.setPositionSync(_raf.lengthSync());
    _raf.writeStringSync(line);
  }

  void truncate() {
    _raf.truncateSync(0);
  }

  bool isLineDelimiter(String priorChar, String char, String lineDelimiter) {
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
void symlink(
  String existingPath,
  String linkPath,
) {
  var link = Link(linkPath);
  link.createSync(existingPath);
}

///
/// Resolves the a symbolic link
/// to the ultimate target path.
/// The return path will be canonicalized.
/// 
/// e.g.
/// resolveSymLink('/usr/bin/dart) == '/usr/lib/bin/dart'
///
/// throws a FileSystemException if the
/// target path does not exist.
String resolveSymLink(String path) {
  var normalised = canonicalize(path);
  var file = FileSync(normalised);
  return canonicalize(file.resolveSymLink());
}
