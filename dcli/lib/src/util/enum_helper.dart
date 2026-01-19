/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'recase.dart';

///
/// Provides a collection of methods that help when working with
/// enums.
///
class EnumHelper {
  static final _self = EnumHelper._init();

  /// Factory Constructor.
  factory EnumHelper() => _self;

  EnumHelper._init();

  /// returns an enum based on its index.
  T getByIndex<T>(List<T> values, int index) => values.elementAt(index - 1);

  /// returns the index of a enum value.
  int getIndexOf<T>(List<T> values, T value) => values.indexOf(value);

  ///
  /// Returns the Enum name without the enum class.
  /// e.g. DayName.Wednesday becomes Wednesday.
  /// By default we recase the value to Title Case.
  /// You can pass an alternate method to control the format.
  ///
  String getName<T>(T enumValue) {
    final name = enumValue.toString();
    final period = name.indexOf('.');

    return ReCase().titleCase(name.substring(period + 1));
  }

    /// returns a enum based on its name.
  /// Throws [Exception].
  /// @Throwing(Exception)
  T getEnum<T>(String enumName, List<T> values) {
    final cleanedName = ReCase().titleCase(enumName);
    for (var i = 0; i < values.length; i++) {
      if (cleanedName == getName(values[i])) {
        return values[i];
      }
    }
    throw Exception("$cleanedName doesn't exist in the list of enums $values");
  }
}
