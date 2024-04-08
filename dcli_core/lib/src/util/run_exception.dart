/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';

import 'dcli_exception.dart';

/// Thrown when any of the process related method
/// such as .run and .start fail.
class RunException extends DCliException {
  ///
  RunException(
    this.cmdLine,
    this.exitCode,
    this.reason, {
    Trace? stackTrace,
  }) : super(reason, stackTrace);

  RunException.fromJson(Map<String, dynamic> json)
      : cmdLine = json['cmdLine'] as String,
        exitCode = json['exitCode'] as int,
        reason = json['reason'] as String,
        super(json['reason'] as String, json['stackTrace'] as Trace);

  factory RunException.fromJsonString(String jsonString) {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return RunException(
      jsonMap['cmdLine'] as String,
      jsonMap['exitCode'] as int,
      jsonMap['reason'] as String,
      stackTrace: jsonMap['stackTrace'] != null
          ? Trace.parse(jsonMap['stackTrace'] as String)
          : null,
    );
  }

  ///
  RunException.withArgs(
    String? cmd,
    List<String?> args,
    this.exitCode,
    this.reason, {
    Trace? stackTrace,
  })  : cmdLine = '$cmd ${args.join(' ')}',
        super(reason, stackTrace);

  ///
  RunException.fromException(
    Object exception,
    String? cmd,
    List<String?> args, {
    Trace? stackTrace,
  })  : cmdLine = '$cmd ${args.join(' ')}',
        reason = exception.toString(),
        exitCode = -1,
        super(exception.toString(), stackTrace);

  /// The command line that was being run.
  String cmdLine;

  /// the exit code of the command.
  int? exitCode;

  /// the error.
  String reason;

  @override
  String get message => '''
$cmdLine 
exit: $exitCode
reason: $reason''';

  Map<String, dynamic> toJsonMap() => {
        'cmdLine': cmdLine,
        'exitCode': exitCode,
        'reason': reason,
        'stackTrace': stackTrace,
      };

  @override
  String toJsonString() {
    final jsonMap = <String, dynamic>{
      'cmdLine': cmdLine,
      'exitCode': exitCode,
      'reason': reason,
      'stackTrace': stackTrace.toString(),
    };
    final json = jsonEncode(jsonMap);
    print(json);
    return json;
  }
}
