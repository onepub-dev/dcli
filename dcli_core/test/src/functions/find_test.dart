/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('find stream', () async {
    var count = 0;
    final controller = LimitedStreamController<FindItem>(100);
    try {
      late StreamSubscription<FindItem>? sub;
      sub = controller.stream.listen(
          (item) => count++); // print(replaceNonPrintable(item.pathTo)));
      await find(
        '*',
        includeHidden: true,
        workingDirectory: pwd,
        progress: controller,
      );
      await sub.cancel();
      sub = null;
    } finally {
      await controller.close();
    }
    print('Count $count Files and Directories found');
    expect(count, greaterThan(0));
  });
}

/// Replaces all non-printable characters in value with a space.
/// tabs, newline etc are all considered non-printable.
// String replaceNonPrintable(String value, {String replaceWith = ' '}) {
//   final charCodes = <int>[];

//   for (final codeUnit in value.codeUnits) {
//     if (isPrintable(codeUnit)) {
//       charCodes.add(codeUnit);
//     } else {
//       if (replaceWith.isNotEmpty) {
//         charCodes.add(replaceWith.codeUnits[0]);
//       }
//     }
//   }

//   return String.fromCharCodes(charCodes);
// }

// bool isPrintable(int codeUnit) {
//   var printable = true;

//   if (codeUnit < 33) {
//     printable = false;
//   }
//   if (codeUnit >= 127) {
//     printable = false;
//   }

//   return printable;
// }
