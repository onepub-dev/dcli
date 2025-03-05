/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
