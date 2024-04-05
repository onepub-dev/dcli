/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

class ProgressLineSplitter {
  ProgressLineSplitter(List<int> intList) {
    final currentLine = StringBuffer();
    var lastWasCR = false;

    for (final value in intList) {
      if (lastWasCR) {
        if (value == '\n'.codeUnitAt(0)) {
          // If last was CR and current is LF, terminate the line
          lines.add(currentLine.toString());
          currentLine.clear();
        } else {
          // If last was CR but current is not LF, add a new line
          lines.add(currentLine.toString());
          currentLine
            ..clear()
            ..writeCharCode(value);
        }
        lastWasCR = false;
      } else {
        if (value == '\r'.codeUnitAt(0)) {
          lastWasCR = true;
        } else if (value == '\n'.codeUnitAt(0)) {
          // If current is LF, terminate the line
          lines.add(currentLine.toString());
          currentLine.clear();
        } else {
          // Otherwise, append the character
          currentLine.writeCharCode(value);
        }
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine.toString());
    }
  }
  final lines = <String>[];
}
