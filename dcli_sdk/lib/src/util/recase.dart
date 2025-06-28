/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// provides methods to change the case of a sentence or word.
class ReCase {
  /// The first letter of each word in the sentence is set to
  /// upper case and the reset lower case.
  String titleCase(String sentence) {
    var words = sentence.split(' ');
    words = words.map(properCase).toList();
    return words.join(' ');
  }

  /// first letter uppercase, rest lower case
  String properCase(String word) => '${word.substring(0, 1).toUpperCase()}'
      '${word.substring(1).toLowerCase()}';
}
