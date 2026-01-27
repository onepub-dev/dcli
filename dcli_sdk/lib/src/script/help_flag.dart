/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'flag.dart';

class HelpFlag extends Flag {
  static const _flagName = 'help';

  static final _self = HelpFlag._internal();

  String? _option;

  ///
  factory HelpFlag() => _self;

  ///
  HelpFlag._internal() : super(_flagName);

  @override
  // Path to the logfile to write verbose log messages to.
  String get option => _option!;

  /// true if the flag has an option.
  bool get hasOption => _option != null;

  @override
  bool get isOptionSupported => false;

  @override
  set option(String? value) {}

  @override
  String get abbreviation => 'v';

  @override
  String usage() => '--$_flagName';

  @override
  String description() => '''
      Displays this help message.
''';
}
