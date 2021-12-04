@Timeout(Duration(minutes: 20))
import 'dart:async';

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('find stream', () async {
    final controller = StreamController<FindItem>();
    try {
      controller.stream
          .listen((item) => print(replaceNonPrintable(item.pathTo)));
      await find(
        '*',
        includeHidden: true,
        workingDirectory:
            // DartProject
            //     .self.pathToProjectRoot,
            pwd,
        progress: controller,
      );
    } finally {
      await controller.close();
    }
  });
}

/// Replaces all non-printable characters in value with a space.
/// tabs, newline etc are all considered non-printable.
String replaceNonPrintable(String value, {String replaceWith = ' '}) {
  final charCodes = <int>[];

  for (final codeUnit in value.codeUnits) {
    if (isPrintable(codeUnit)) {
      charCodes.add(codeUnit);
    } else {
      if (replaceWith.isNotEmpty) {
        charCodes.add(replaceWith.codeUnits[0]);
      }
    }
  }

  return String.fromCharCodes(charCodes);
}

bool isPrintable(int codeUnit) {
  var printable = true;

  if (codeUnit < 33) {
    printable = false;
  }
  if (codeUnit >= 127) {
    printable = false;
  }

  return printable;
}
