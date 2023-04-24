// @dart=3.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

//
// POSIX threading primitives
//

/// Represents `pthread_mutex_t`
final class PthreadMutex extends Opaque {}

/// Represents `pthread_cond_t`
final class PthreadCond extends Opaque {}

@Native<Int Function(Pointer<PthreadMutex>, Pointer<Void>)>()
external int pthread_mutex_init(
    Pointer<PthreadMutex> mutex, Pointer<Void> attrs);

@Native<Int Function(Pointer<PthreadMutex>)>()
external int pthread_mutex_lock(Pointer<PthreadMutex> mutex);

@Native<Int Function(Pointer<PthreadMutex>)>()
external int pthread_mutex_unlock(Pointer<PthreadMutex> mutex);

@Native<Int Function(Pointer<PthreadCond>, Pointer<Void>)>()
external int pthread_cond_init(Pointer<PthreadCond> cond, Pointer<Void> attrs);

@Native<Int Function(Pointer<PthreadCond>, Pointer<PthreadMutex>)>()
external int pthread_cond_wait(
    Pointer<PthreadCond> cond, Pointer<PthreadMutex> mutex);

@Native<Int Function(Pointer<PthreadCond>)>()
external int pthread_cond_signal(Pointer<PthreadCond> cond);

/// Runs [body] with [mutex] locked.
R lock<R>(Pointer<PthreadMutex> mutex, R Function() body) {
  check(pthread_mutex_lock(mutex));
  try {
    return body();
  } finally {
    check(pthread_mutex_unlock(mutex));
  }
}

void check(int retval) {
  if (retval != 0) throw 'operaton failed';
}

//
// Single producer single consumer mailbox for synchronous communication
// between two isolates.
//

final class _MailboxRepr extends Struct {
  external Pointer<Uint8> buffer;

  @Int32()
  external int bufferLength;

  @Int32()
  external int state;
}

extension on Pointer<_MailboxRepr> {
  Pointer<PthreadMutex> get mutex =>
      Pointer<PthreadMutex>.fromAddress(address + Mailbox.mutexOffs);
  Pointer<PthreadCond> get condRequest =>
      Pointer<PthreadCond>.fromAddress(address + Mailbox.condRequestOffs);
  Pointer<PthreadCond> get condResponse =>
      Pointer<PthreadCond>.fromAddress(address + Mailbox.condResponseOffs);
}

/// This class allows two isolates (a worker and a dispatcher isolate which
/// spawned it) to communicate synchronously. Dispatcher sends a request to the
/// worker and synchronously waits for response to arrive.
class Mailbox {
  static final int mutexSize = 64;
  static final int condSize = 64;
  static final int headerSize = sizeOf<_MailboxRepr>();
  static final int mutexOffs = headerSize;
  static final int condRequestOffs = mutexOffs + mutexSize;
  static final int condResponseOffs = condRequestOffs + condSize;
  static final int totalSize = condResponseOffs + condSize;

  final Pointer<_MailboxRepr> _mailbox;
  bool isRunning = true;

  static const stateNone = 0;
  static const stateRequest = 1;
  static const stateResponse = 2;

  /// Create a new mailbox for communication between dispatcher and the worker.
  Mailbox() : _mailbox = calloc.allocate(Mailbox.totalSize) {
    check(pthread_mutex_init(_mailbox.mutex, nullptr));
    check(pthread_cond_init(_mailbox.condRequest, nullptr));
    check(pthread_cond_init(_mailbox.condResponse, nullptr));
  }

  /// Create a mailbox pointing to an already existing mailbox.
  Mailbox.fromAddress(int address) : _mailbox = Pointer.fromAddress(address);

  /// Send the given [message] to the worker isolate and wait for it to
  /// produce a response.
  ///
  /// Performance note: [message] is copied into native memory and response is
  /// copied from native memory into the Dart heap.
  Uint8List sendRequest(Uint8List message) {
    final buffer = _toBuffer(message);
    return _toList(lock(_mailbox.mutex, () {
      if (_mailbox.ref.state != stateNone) {
        throw 'Illegal Mailbox state';
      }

      _mailbox.ref.state = stateRequest;
      _mailbox.ref.buffer = buffer;
      _mailbox.ref.bufferLength = message.length;

      // Wake the worker.
      pthread_cond_signal(_mailbox.condRequest);

      // Wait for it to produce the result.
      while (_mailbox.ref.state != stateResponse) {
        pthread_cond_wait(_mailbox.condResponse, _mailbox.mutex);
      }

      // Handle the result.
      _mailbox.ref.state = stateNone;
      final response =
          (buffer: _mailbox.ref.buffer, length: _mailbox.ref.bufferLength);
      _mailbox.ref.buffer = nullptr;
      _mailbox.ref.bufferLength = 0;
      return response;
    }));
  }

  void respond(Uint8List? message) {
    if (_mailbox.ref.state != stateNone) {
      throw 'Invalid state: ${_mailbox.ref.state}';
    }

    final buffer = message != null ? _toBuffer(message) : nullptr;
    lock(_mailbox.mutex, () {
      if (_mailbox.ref.state != stateNone) {
        throw 'Invalid state: ${_mailbox.ref.state}';
      }

      _mailbox.ref.state = stateResponse;
      _mailbox.ref.buffer = buffer;
      _mailbox.ref.bufferLength = message?.length ?? 0;
      pthread_cond_signal(_mailbox.condResponse);
    });
  }

  static final _emptyResponse = Uint8List(0);

  Uint8List takeOne() => lock(_mailbox.mutex, () {
        // Wait for request to arrive.
        while (_mailbox.ref.state != stateResponse) {
          pthread_cond_wait(_mailbox.condResponse, _mailbox.mutex);
        }

        final result = _toList(
            (buffer: _mailbox.ref.buffer, length: _mailbox.ref.bufferLength));

        _mailbox.ref.state = stateNone;
        _mailbox.ref.buffer = nullptr;
        _mailbox.ref.bufferLength = 0;
        return result;
      });

  /// Process messages which arrive to this mailbox.
  ///
  /// Calls [handleMessage] for each incoming message and then sends the
  /// response it produces back to the requestor. [msg] buffer is only valid
  /// for the duration of the [handleMessage] callback.
  ///
  /// Performance note: copies response to the native memory.
  void messageLoop(
      Uint8List Function(Mailbox mailbox, Uint8List msg) handleMessage) {
    lock(_mailbox.mutex, () {
      while (isRunning) {
        // Wait for request to arrive.
        while (_mailbox.ref.state != stateRequest) {
          pthread_cond_wait(_mailbox.condRequest, _mailbox.mutex);
        }

        final response = handleMessage(
            this, _mailbox.ref.buffer.asTypedList(_mailbox.ref.bufferLength));
        malloc.free(_mailbox.ref.buffer);

        _mailbox.ref.state = stateResponse;
        _mailbox.ref.buffer = _toBuffer(response);
        _mailbox.ref.bufferLength = response.length;
        pthread_cond_signal(_mailbox.condResponse);
      }
    });
  }

  int get rawAddress => _mailbox.address;

  static Uint8List _toList(({Pointer<Uint8> buffer, int length}) data) {
    if (data.length == 0) {
      return _emptyResponse;
    }

    // Ideally we would like just to do `buffer.asTypedList(length)` and
    // have finaliser take care of freeing, but we currently can't express
    // this in pure Dart in a reliable way without some hacks - because
    // [Finalizer] only runs callbacks at the top of the event loop and
    // [NativeFinalizer] does not accept Dart functions as a finalizer.
    final list = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) list[i] = data.buffer[i];
    malloc.free(data.buffer);
    return list;
  }

  static Pointer<Uint8> _toBuffer(Uint8List list) {
    final buffer = malloc.allocate<Uint8>(list.length);
    for (var i = 0; i < list.length; i++) buffer[i] = list[i];
    return buffer;
  }
}
