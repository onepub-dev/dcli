/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import '../util/exceptions.dart';
import 'flag.dart';

///
class VerboseFlag extends Flag {
  static const _flagName = 'verbose';

  static final _self = VerboseFlag._internal();

  String? _option;

  ///
  factory VerboseFlag() => _self;

  ///
  VerboseFlag._internal() : super(_flagName);

  @override
  // Path to the logfile to write verbose log messages to.
  String get option => _option!;

  /// true if the flag has an option.
  bool get hasOption => _option != null;

  @override
  bool get isOptionSupported => true;

  @override
  set option(String? value) {
    // check that the value contains a path and that
    // the path exists.
    if (!exists(dirname(value!))) {
      throw InvalidFlagOptionException(
        "The log file's directory '${truepath(dirname(value))} "
        'does not exists. '
        'Create the directory first.',
      );
    } else {
      _option = value;
      touch(value, create: true);
      value.truncate();
    }
  }

  @override
  String get abbreviation => 'v';

  @override
  String usage() => '--$_flagName[=<log path>] | -$abbreviation[=<log path>]';

  @override
  String description() => '''
      If passed, turns on verbose logging to the console.
      If you provide a log path then logging is written to the given logfile.''';
}
