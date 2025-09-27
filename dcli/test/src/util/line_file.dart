/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';
import 'dart:io';

import 'package:dcli_core/src/util/platform.dart';

/// Provide s collection of methods to make it easy
/// to read/write a file line by line.
class LineFile {
  final FileMode _fileMode;

  late final File _file;

  late final RandomAccessFile _raf = _open(_fileMode);

  /// If you instantiate FileSync you MUST call [close].
  ///
  /// We rececommend that you use withOpenFile in prefernce to directly
  /// calling this method.
  LineFile(String path, {FileMode fileMode = FileMode.writeOnlyAppend})
      : _fileMode = fileMode {
    _file = File(path);
  }

  RandomAccessFile _open(FileMode fileMode) => _file.openSync(mode: fileMode);

  ///
  /// Flushes the contents of the file to disk.
  void flush() => _raf.flushSync();

  /// Returns the length of the file in bytes
  /// The file does NOT have to be open
  /// to determine its length.
  int get length => _file.lengthSync();

  /// Close and flushes the file to disk.
  void close() => _raf.closeSync();

  /// Read file line by line.
  void readAll(bool Function(String) handleLine) {
    final stream = _file.openSync();
    try {
      final splitter =
          const LineSplitter().startChunkedConversion(CallbackStringSync((str) {
        if (!handleLine(str)) {
          throw const _StopIteration();
        }
      }));

      final decoder = const Utf8Decoder().startChunkedConversion(splitter);

      while (true) {
        final bytes = stream.readSync(16 * 1024);
        if (bytes.isEmpty) {
          break;
        }
        decoder.add(bytes);
      }
      decoder.close();
    } on _StopIteration catch (_) {
      // Ignore.
    } finally {
      stream.closeSync();
    }
  }

  /// Truncates the file to zero bytes and
  /// then writes the given text to the file.
  /// If [newline] is null or isn't passed then the platform
  /// end of line characters are appended as defined by
  /// [Platform().eol].
  /// Pass null or an '' to [newline] to not add a line terminator.
  void write(String line, {String? newline}) {
    final finalline = line + (newline ?? eol);
    _raf
      ..truncateSync(0)
      ..setPositionSync(0)
      ..writeStringSync(finalline)
      ..flushSync();
  }

  /// Appends the [line] to the file
  /// Appends [newline] after the line.
  /// If [newline] is null or isn't passed then the platform
  /// end of line characters are appended as defined by
  /// [Platform().eol].
  /// Pass null or an '' to [newline] to not add a line terminator.
  void append(String line, {String? newline}) {
    final finalline = line + (newline ?? eol);

    _raf
      ..setPositionSync(_raf.lengthSync())
      ..writeStringSync(finalline);
  }

  /// Reads a single line from the file.
  /// [lineDelimiter] the end of line delimiter.
  /// May be one or two characters long.
  /// Defaults to the platform specific delimiter as
  /// defined by  [Platform().eol].
  ///
  String? read({String? lineDelimiter}) {
    lineDelimiter ??= eol;
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
    final endOfFile = line.isEmpty && !foundDelimiter;
    return endOfFile ? null : line.toString();
  }

  /// Truncates the file to zero bytes in length.
  void truncate() => _raf.truncateSync(0);

  bool _isLineDelimiter(String priorChar, String char, String lineDelimiter) {
    if (lineDelimiter.length == 1) {
      return char == lineDelimiter;
    } else {
      return priorChar + char == lineDelimiter;
    }
  }

  /// Opens the file for random access.
  void open() {
    /// accessing raf causes the file to open.
    // ignore: unnecessary_statements
    _raf;
  }
}

/// Opens a File and calls [action] passing in the open [LineFile].
/// When action completes the file is closed.
/// Use this method in preference to directly callling [FileSync()]
R withOpenLineFile<R>(
  String pathToFile,
  R Function(LineFile) action, {
  FileMode fileMode = FileMode.writeOnlyAppend,
}) {
  final file = LineFile(pathToFile, fileMode: fileMode)..open();

  late R result;
  try {
    result = action(file);
  } finally {
    file
      ..flush()
      ..close();
  }
  return result;
}

class _StopIteration implements Exception {
  const _StopIteration();
}

class CallbackStringSync implements Sink<String> {
  final void Function(String) callback;

  CallbackStringSync(this.callback);

  @override
  void add(String data) {
    callback(data);
  }

  @override
  void close() {}
}
