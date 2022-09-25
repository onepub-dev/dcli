@Timeout(Duration(minutes: 5))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test(
    'menu - defaultValue',
    () {
      final options = ['public', 'private'];

      var result = menu(
        'How old are you',
        defaultOption: null,
        options: options,
      );
      print('result: $result');

      result = menu(
        'How old are you',
        defaultOption: 'public',
        options: options,
      );
      print('result: $result');

      final numoptions = [3.14, 8.9];
      final result1 = menu(
        'How old are you',
        defaultOption: 8.9,
        options: numoptions,
      );
      print('result: $result1');

      try {
        menu('How old are you', defaultOption: 9, options: numoptions);
        // ignore: avoid_catching_errors
      } on ArgumentError catch (e) {
        print('Expected Argument error ${e.toString()}');
      }
      print('result: $result1');
    },
    skip: true,
  );

  test(
    'One entry',
    () {
      menu('only one', options: ['One'], limit: 20);
    },
    skip: true,
    tags: ['console'],
  );
}
