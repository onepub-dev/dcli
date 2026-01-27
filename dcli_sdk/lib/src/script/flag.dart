/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// base class for command line flags (--name, -v ...)
abstract class Flag {
  final String _name;

  ///
  const Flag(this._name);

  /// name of the flag
  String get name => _name;

  /// abbreviation for the flag.
  String get abbreviation;

  /// return true if the flag can take a value
  /// after an equals sign
  /// e.g. -v=/var/log/syslog
  bool get isOptionSupported => false;

  /// returns the usage for this flag
  String usage() => '--$_name | -$abbreviation';

  @override
  // we only depend on immutable fields.
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(covariant Flag other) => other.name == _name;

  @override
  // we only depend on immutable fields.
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => name.hashCode;

  /// [Flag] implementations must overload this to return a
  /// description of the flag used in the usage statement.
  String description();

  /// Called if an option is passed to a flag
  /// and the flag supports options.
  /// If the option value is invalid then throw a
  /// InvalidFlagOption exception.

  /// Override this method if your flag takes an optional argument
  /// after an = sign.
  ///
  set option(String? value) {
    assert(
      !isOptionSupported,
      'You must implement option setter for $_name flag',
    );
  }

  /// override this method if your flag takes an optional argument
  /// after an = sign.
  /// this method should reutrn the value after the = sign.
  String? get option => null;
}
