/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';

/// Base class for all DCli exceptions.
class DCliException implements Exception {
  ///
  DCliException(this.message, [Trace? stackTrace])
      : cause = null,
        stackTrace = stackTrace ?? Trace.current(2);

  // Factory method to create DCliException from a JSON string
  factory DCliException.fromJson(String jsonStr) {
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;

    return DCliException._(
      jsonMap['message'] as String,
      jsonMap['cause'] as String,
      Trace.parse(jsonMap['stackTrace'] as String),
    );
  }

  DCliException._(this.message, this.cause, [Trace? stackTrace])
      : stackTrace = stackTrace ?? Trace.current(2);

  ///
  DCliException.from(this.cause, this.stackTrace) : message = cause.toString();

  ///
  DCliException.fromException(this.cause)
      : message = cause.toString(),
        stackTrace = Trace.current(2);

  ///
  final String message;

  /// If DCliException is wrapping another exception then this is the
  /// exeception that is wrapped.
  final Object? cause;

  ///
  Trace stackTrace;

  //  {
  //   return DCliException(this.message, stackTrace);
  // }

  @override
  String toString() => message;

  ///
  void printStackTrace() {
    print(stackTrace.terse);
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'cause': cause?.toString(),
        'stackTrace': stackTrace.toString(),
      };

  // Method to convert DCliException to a JSON string
  String toJsonString() => jsonEncode(toJson());
}
