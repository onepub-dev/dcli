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
    find(
      '*',
      includeHidden: true,
      workingDirectory: pwd,
      progress: (_) {
        count++;
        return true;
      },
    );
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
  });
}
