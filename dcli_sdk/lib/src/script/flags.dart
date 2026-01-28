/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

import '../util/exceptions.dart';
import 'flag.dart';
import 'selected_flags.dart';

/// helper flass for manageing flags.
@immutable
class Flags {
  /// Find the flag that matches the name part of [flagSwitch].
  ///
  /// e.g --flagname=value
  /// @Throwing(InvalidFlagOptionException)
  Flag? findFlag(String flagSwitch, List<Flag> flags) {
    Flag? found;
    var foundOption = false;
    var finalFlagSwitch = flagSwitch;

    // Some flags allow an option after an equals sign
    final parts = finalFlagSwitch.split('=');
    if (parts.length == 2) {
      foundOption = true;
      finalFlagSwitch = parts[0];
    }
    for (final flag in flags) {
      if (nameSwitch(flag) == finalFlagSwitch ||
          abbrSwitch(flag) == finalFlagSwitch) {
        if (foundOption) {
          if (flag.isOptionSupported) {
            flag.option = parts[1];
          } else {
            throw InvalidFlagOptionException(
              'The flag $finalFlagSwitch was passed with an option but '
              'it does not support options.',
            );
          }
        }
        found = flag;
        break;
      }
    }
    return found;
  }

  /// the format of a named switch '--name'
  static String nameSwitch(Flag flag) => '--${flag.name}';

  /// the format of an abbreviated switch '-n'
  static String abbrSwitch(Flag flag) => '-${flag.abbreviation}';

  /// true if the given argument starts with '-' or '--'.
  static bool isFlag(String argument) =>
      argument.startsWith('-') || argument.startsWith('--');

  /// true if a global flag in the [Settings] class is set.
  bool isSet(Flag flag) => SelectedFlags().isFlagSet(flag);

  /// sets a global flag in the [Settings] class.
  void set(Flag flag) {
    SelectedFlags().setFlag(flag);
  }
}
