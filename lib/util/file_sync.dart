import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/util/waitForEx.dart';

import 'dshell_exception.dart';
import 'log.dart';
import 'runnable_process.dart';
import 'stack_trace_impl.dart';

class FileSync {
  File _file;
  RandomAccessFile _raf;

  FileSync(String path, {FileMode fileMode = FileMode.writeOnlyAppend}) {
    _file = File(path);
    _open(fileMode: fileMode);
  }

  void _open({FileMode fileMode = FileMode.read}) {
    _raf = _file.openSync(mode: fileMode);
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

  /// Truncates the file to zero bytes and
  /// then writes the given text to the file.
  void write(String line, {bool newline = true}) {
    if (newline) {
      line += '\n';
    }
    _raf.truncateSync(0);

    _raf.setPositionSync(0);
    _raf.flushSync();

    _raf.writeStringSync(line);
  }

  /// Appends the [line] to the file
  /// If [newLine] is true then append a newline after the line.
  void append(String line, {bool newline = true}) {
    if (newline) {
      line += '\n';
    }
    _raf.setPositionSync(_raf.lengthSync());
    _raf.writeStringSync(line);
  }

  void truncate() {
    _raf.truncateSync(0);
  }
}
