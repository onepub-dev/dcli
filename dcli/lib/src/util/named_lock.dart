/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async' show FutureOr;

import 'package:runtime_named_locks/runtime_named_locks.dart' as runtime;
import 'package:stack_trace/stack_trace.dart' show Trace;

import '../../dcli.dart' show DCliException, verbose;

/// A [NamedLock] can be used to control access to a resource
/// across processes and isolates.
class NamedLock {
  /// !!DEPRECATED!! [lockPath] was the path of the directory used
  /// to store the lock file. This is no longer used.
  ///
  /// All code that shares the lock MUST use the
  /// same [suffix].
  /// The [suffix] is used as the suffix of the named semaphore name.
  /// The suffix allows multiple locks to share a single
  /// semaphore name.
  ///
  /// The [description], if passed, is used in error messages
  /// to describe the lock.
  /// The [timeout] defines how long we will wait for
  /// a lock to become available. The default [timeout] is
  /// infinite (null).
  ///
  /// ```dart
  /// NamedLock(name: 'update-catalog', suffix: my-script).withLock(() {
  ///   if (!exists('catalog'))
  ///     createDir('catalog');
  ///   updateCatalog();
  /// });
  /// ```
  NamedLock({
    required this.suffix,
    // TODOperhaps we keep this in tact and end up doing a hash
    // on it to create the name?
    // ignore: avoid_unused_constructor_parameters
    String? lockPath,
    String description = '',
    String name = 'dcli.lck',
    Duration timeout = const Duration(seconds: 30),
  })  : _timeout = timeout,
        _description = description,
        _nameWithSuffix = [name, suffix].join('.');

  /// The name of the lock which is used to create the a
  /// native named semaphore under the hood.
  final String _nameWithSuffix;

  /// The name of the lock.
  final String suffix;

  /// The description of the lock for error messages.
  /// TODO @tsavo-at-pieces - layer this into named locks package
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
  FutureOr<void> withLock(
    FutureOr<void> Function() action, {
    String? waiting,
  }) async {
    final callingStackTrace = Trace.current();

    final execution = runtime.ExecutionCall<FutureOr<void>, DCliException>(
      callable: () => action(),
      safe: true,
    );

    try {
      verbose(() => 'withLock called for $_nameWithSuffix');

      // Note that guarded here is the same insance as execution above
      final _execution = runtime.NamedLock.guard<FutureOr<void>, DCliException>(
        name: _nameWithSuffix,
        execution: execution,
        waiting: waiting,
        timeout: _timeout,
      );

      if (_execution.successful.isSet && _execution.successful.get!) {
        await _execution.completer.future;
        await _execution.returned;
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
  }
}

class LockException extends DCliException {
  LockException(super.message);
}
