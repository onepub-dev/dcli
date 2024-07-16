/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:runtime_named_locks/runtime_named_locks.dart' as runtime;
import 'package:runtime_named_locks/runtime_named_locks.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

import '../../dcli.dart' show DCliException, verbose;

/// A [NamedLock] can be used to control access to a resource
/// across processes and isolates.
class NamedLock {
  /// All code that shares the lock MUST use the
  /// same [name] and [suffix].
  ///
  /// The [description], if passed, is used in error messages
  /// to describe the lock.
  ///
  /// The [timeout] defines how long we will wait for
  /// a lock to become available. The default [timeout] is
  /// 1 day.
  ///
  /// ```dart
  /// NamedLock(name: 'update-catalog').withLock(() {
  ///   if (!exists('catalog'))
  ///     createDir('catalog');
  ///   updateCatalog();
  /// });
  /// ```
  NamedLock({
    required this.name,
    String description = '',
    String suffix = 'dcli.lck',
    Duration timeout = const Duration(days: 1),
  })  : _timeout = timeout,
        _description = description,
        _nameWithSuffix = [name, suffix].join('.');

  /// The name of the lock which is used to create the a
  /// native named semaphore under the hood.
  final String _nameWithSuffix;

  /// The name of the lock.
  final String name;

  // TODO(tsavo-at-pieces): - layer this into named locks package
  /// The description of the lock for error messages.
  // ignore: flutter_style_todos
  // ignore: unused_field
  final String _description;

  /// The duration to wait for a lock before timing out.
  final Duration _timeout;

  /// creates a lock file and then calls [action]
  /// once [action] returns the lock is released.
  /// If [waiting] is passed it will be used to write
  /// a log message to the console.
  ///
  /// Throws a [DCliException] if the NamedLock times out.
  Future<T> withLock<T>(
    T Function() action, {
    String? waiting,
  }) async {
    final callingStackTrace = Trace.current();

    final execution = runtime.ExecutionCall<T, DCliException>(
      callable: () => action(),
      safe: true,
    );

    ExecutionCall<T, DCliException> _execution;

    try {
      verbose(() => 'withLock called for $_nameWithSuffix');

      // Note that guarded here is the same insance as execution above
      _execution = runtime.NamedLock.guard<T, DCliException>(
        name: _nameWithSuffix,
        execution: execution,
        waiting: waiting,
        timeout: _timeout,
      );

      if (_execution.successful.isSet && _execution.successful.get!) {
        await _execution.completer.future;
      } else if (_execution.error.isSet) {
        await _execution.error.get?.rethrow_();
      }
    } on DCliException catch (e) {
      verbose(() => 'Exception caught for $_nameWithSuffix...  $e : $e');
      throw e..stackTrace = callingStackTrace;
    } on Exception catch (e) {
      verbose(() => 'Exception caught for $_nameWithSuffix... $e : $e');
      throw DCliException.from(e, callingStackTrace);
    } finally {
      verbose(() => 'withLock completed for $_nameWithSuffix');
    }
    return _execution.returned;
  }

  /// creates a lock file and then calls [action]
  /// once [action] returns the lock is released.
  /// If [waiting] is passed it will be used to write
  /// a log message to the console.
  ///
  /// Throws a [DCliException] if the NamedLock times out.
  Future<T> withLockAsync<T>(
    Future<T> Function() action, {
    String? waiting,
  }) async {
    final callingStackTrace = Trace.current();

    final execution = runtime.ExecutionCall<Future<T>, DCliException>(
      callable: () => action(),
      safe: true,
    );

    ExecutionCall<Future<T>, DCliException> _execution;
    try {
      verbose(() => 'withLock called for $_nameWithSuffix');

      // Note that guarded here is the same insance as execution above
      _execution = runtime.NamedLock.guard<Future<T>, DCliException>(
        name: _nameWithSuffix,
        execution: execution,
        waiting: waiting,
        timeout: _timeout,
      );

      if (_execution.successful.isSet && _execution.successful.get!) {
        await await _execution.completer.future;
      } else if (_execution.error.isSet) {
        await _execution.error.get?.rethrow_();
      }
    } on DCliException catch (e) {
      verbose(() => 'Exception caught for $_nameWithSuffix...  $e : $e');
      throw e..stackTrace = callingStackTrace;
    } on Exception catch (e) {
      verbose(() => 'Exception caught for $_nameWithSuffix... $e : $e');
      throw DCliException.from(e, callingStackTrace);
    } finally {
      verbose(() => 'withLock completed for $_nameWithSuffix');
    }
    return _execution.returned;
  }
}

class LockException extends DCliException {
  LockException(super.message);
}
