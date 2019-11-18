import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/util/waitFor.dart';

import 'dshell_exception.dart';
import 'log.dart';
import 'runnable_process.dart';
import 'stack_trace_impl.dart';

class FileSync {
  File _file;
  RandomAccessFile _raf;

  FileSync(String path, {FileMode fileMode = FileMode.read}) {
    _file = File(path);
    _open(fileMode: fileMode);
  }

  FileSync.fromStdIn(Stdin stdIn);

  void _open({FileMode fileMode = FileMode.read}) {
    _raf = _file.openSync(mode: fileMode);
  }

  ///
  /// Flushes the contents of the file to disk.
  void flush() {
    _raf.flushSync();
  }

  int get length {
    return _raf.lengthSync();
  }

  // close also flushes a file.
  void close() {
    _raf.closeSync();
  }

  void read(CancelableLineAction lineAction) {
    Stream<List<int>> inputStream = _file.openRead();

    StackTraceImpl stackTrace = StackTraceImpl();

    Object exception;

    Completer<bool> done = Completer();
    // bool stop = false;

    try {
      StreamSubscription<String> subscription;

      subscription =
          utf8.decoder.bind(inputStream).transform(const LineSplitter()).listen(
              (line) {
                if (lineAction != null) {
                  bool cont = lineAction(line);
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
      Log.e("exception $e");
    }

    waitFor(done.future);

    if (exception != null) {
      if (exception is _CancelReadException) {
        // not an exception, the user just doesn't want to continue.
      } else {
        throw DShellException.from(exception, stackTrace);
      }
    }
  }

  FileStat stat() {
    return _file.statSync();
  }

  void write(String line, {bool newline = true}) {
    if (newline) {
      line += '\n';
    }
    _raf.writeStringSync(line);
  }

  void append(String line, {bool newline = true}) {
    if (newline) {
      line += '\n';
    }
    _raf.setPositionSync(_raf.lengthSync());
    _raf.writeStringSync(line);
  }
}

class _CancelReadException implements Exception {}
