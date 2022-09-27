import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../../dcli.dart';
import '../util/circular_buffer.dart';

class BlockQueue {
  BlockQueue(this.stream) {
    stream.listen((block) {
      _blockQueue.addFirst(block);
      //  print('added  ${block.length}');
      if (!dataLoaded.isCompleted) {
        dataLoaded.complete(true);
        print('completed');
      }
    });
  }

  bool closed = false;

  Completer<bool> dataLoaded = Completer<bool>();

  static const _cr = 13;
  static const _lf = 10;

  Stream<List<int>> stream;

  /// holds blocks as they are read from the stream.
  final Queue<List<int>> _blockQueue = Queue<List<int>>();

  /// Holds a single block that we are processing.
  CircularBuffer<int> _blockBuffer = CircularBuffer(0);

  Future<int> readByte() async {
    if (_blockBuffer.isEmpty) {
      // pump the event loop so it can deliver more data.
      await Future.delayed(Duration.zero, () {});

      if (_blockQueue.isEmpty) {
        if (closed) {
          return -1;
        }
        // wait for new data to arrive
        await dataLoaded.future;
        print('loaded');
      }

      /// move a block from the queue into the block buffer.
      final block = _blockQueue.removeLast();
      if (_blockQueue.isEmpty) {
        dataLoaded = Completer<bool>();
        print('empty');
      }
      print('blocksize ${block.length}');
      final line = <int>[];

      block.forEach(line.add);
      _blockBuffer = CircularBuffer.fromList(line);
    }

    return _blockBuffer.next();
  }

  // ignore: discarded_futures
  int readByteSync() => waitForEx(readByte());

  /// Reads a line from stdin.
  ///
  /// Copied from Stdin
  ///
  /// Blocks until a full line is available.
  ///
  /// Lines my be terminated by either `<CR><LF>` or `<LF>`. On Windows,
  /// in cases where the [stdioType] of stdin is [StdioType.terminal],
  /// the terminator may also be a single `<CR>`.
  ///
  /// Input bytes are converted to a string by [encoding].
  /// If [encoding] is omitted, it defaults to [systemEncoding].
  ///
  /// If [retainNewlines] is `false`, the returned string will not include the
  /// final line terminator. If `true`, the returned string will include t
  /// he line terminator. Default is `false`.
  ///
  /// If end-of-file is reached after any bytes have been read from stdin,
  /// that data is returned without a line terminator.
  /// Returns `null` if no bytes preceded the end of input.
  String? readLineSync(
      {required StdioType stdioType,
      required Encoding encoding,
      required bool retainNewlines,
      required bool lineMode}) {
    final line = <int>[];

    if (retainNewlines) {
      int byte;
      do {
        byte = readByteSync();
        if (byte < 0) {
          break;
        }
        line.add(byte);
      } while (
          byte != _lf && !(byte == _cr && _crIsNewline(stdioType, lineMode)));
      if (line.isEmpty) {
        return null;
      }
    } else if (_crIsNewline(stdioType, lineMode)) {
      // CR and LF are both line terminators, neither is retained.
      while (true) {
        final byte = readByteSync();
        if (byte < 0) {
          if (line.isEmpty) {
            return null;
          }
          break;
        }
        if (byte == _lf || byte == _cr) {
          break;
        }
        line.add(byte);
      }
    } else {
      // Case having to handle CR LF as a single unretained line terminator.
      outer:
      while (true) {
        var byte = readByteSync();
        if (byte == _lf) {
          break;
        }
        if (byte == _cr) {
          do {
            byte = readByteSync();
            if (byte == _lf) {
              break outer;
            }

            line.add(_cr);
            // ignore: invariant_booleans
          } while (byte == _cr);
          // Fall through and handle non-CR character.
        }
        if (byte < 0) {
          if (line.isEmpty) {
            return null;
          }
          break;
        }
        line.add(byte);
      }
    }
    return encoding.decode(line);
  }

  // On Windows, if lineMode is disabled, only CR is received.
  bool _crIsNewline(StdioType stdioType, bool lineMode) =>
      Platform.isWindows && (stdioType == StdioType.terminal) && !lineMode;

  void close() {
    closed = true;
    // we need to wake up the reader
    dataLoaded.complete(true);
  }
}
