/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('find stream', () async {
    var count = 0;
    await for (final file in findAsync(
      '*',
      includeHidden: true,
      workingDirectory: pwd,
    )) {
      print(file);
      count++;
    }
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
  });
}
