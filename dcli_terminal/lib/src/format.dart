/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// provides a random collection of formatters
/// EXPERIMENTAL
///
class Format {
  /// Factory constructor.
  factory Format() => _self;
  Format._internal();

  static final _self = Format._internal();

  /// [cols] is a list of strings (the columns) that
  /// are to be formatted as a set of fixed with
  /// columns.
  ///
  /// As this is a fixed width row colums that exceed the given
  /// width will be clipped.
  /// You can make any column variable width by passing -1 as the width.
  ///
  /// By default there is a single space between each column you
  /// can pass a [delimiter] to modify this behaviour. You can
  /// suppress the [delimiter] by passing an empty string ''.
  ///
  /// [widths] defines the width of each column in the row.
  ///
  /// If their are more [cols] than [widths] then the last width
  /// is used repeatedly.
  /// If [widths] is null then a default width of 20 is used.
  ///
  /// returns a string with each of the columns padded according to the
  /// [widths].
  ///
  ///
  String row(
    List<String?> cols, {
    List<int>? widths,
    List<TableAlignment>? alignments,
    String? delimiter,
  }) {
    var row = '';
    var i = 0;
    widths ??= [20];
    var width = widths[0];

    alignments ??= [TableAlignment.left];
    var alignment = alignments[0];

    delimiter ??= ' ';

    for (var col in cols) {
      if (row.isNotEmpty) {
        row += delimiter;
      }

      /// make row robust if a null col is passed.
      col ??= '';
      var colwidth = col.length;
      if (colwidth > width) {
        colwidth = width;
        if (width != -1) {
          col = col.substring(0, width);
        }
      }
      switch (alignment) {
        case TableAlignment.left:
          row += col.padRight(width);
        case TableAlignment.right:
          row += col.padLeft(width);
        case TableAlignment.middle:
          final padding = width = colwidth;
          row += col.padLeft(padding);
      }

      i++;

      if (i < widths.length) {
        width = widths[i];
      }
      if (i < alignments.length) {
        alignment = alignments[i];
      }
    }
    return row;
  }

  /// Limits the [display] string's length to [width] by removing the centre
  /// components of the string and replacing them with '...'
  ///
  /// Example:
  /// var long = 'http://www.onepub.dev/some/long/url';
  /// print(limitString(long, width: 20))
  /// > http://...ong/url
  String limitString(String display, {int width = 40}) {
    if (display.length <= width) {
      return display;
    }
    final elipses = width <= 2 ? 1 : 3;
    final partLength = (width - elipses) ~/ 2;
    return '''
${display.substring(0, partLength)}${'.' * elipses}${display.substring(display.length - partLength)}''';
  }

  /// returns a double as a percentage to the given [precision]
  /// e.g. 0.11 becomes 11% if [precision] is 0.
  String percentage(double progress, int precision) =>
      '${(progress * 100).toStringAsFixed(precision)}%';

  /// returns the the number of [bytes] in a human readable
  /// form. e.g. 1e+5 3.000T, 10.00G, 100.0M, 20.00K, 10B
  ///
  /// When [pad] is true
  /// Except for absurdly large no. (> 10^20)
  /// the return is guarenteed to be 6 characters long.
  /// For no. < 9999 we right pad the no. with spaces.
  ///
  /// When [pad] is false
  /// Except for absurdly large no. (> 10^20)
  /// the return is guarenteed to be 6 or less characters long.
  /// Returns [bytes] in a human-readable binary form (base 1024).
  /// Examples: 3.000T, 10.00G, 100.0M, 20.00K, 10B
  ///
  /// With [pad] true (default), the numeric part is left-padded to width 5,
  /// so the whole string is 6 chars incl. the unit (except when using
  /// scientific notation for very large values).
  String bytesAsReadable(int bytes, {bool pad = true}) {
    // Switch to scientific notation from 1 PiB (i.e., 1024^5).
    const petaBytes = 1125899906842624;
    if (bytes >= petaBytes) {
      return bytes.toStringAsExponential(0);
    }

    const units = ['B', 'K', 'M', 'G', 'T'];
    var value = bytes.toDouble();
    var unitIndex = 0;

    // Binary (1024) steps.
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    String numberPart;
    if (unitIndex == 0) {
      // Bytes: integer, pad to width 5 if requested.
      numberPart = value.toInt().toString();
      if (pad) {
        numberPart = numberPart.padLeft(5);
      }
    } else {
      // For K and above, choose decimals so numeric part is exactly 5 chars.
      final intLen = value.floor().toString().length;
      var decimals = 5 - intLen - 1; // reserve 1 for '.'
      if (decimals < 0) {
        decimals = 0;
      }

      numberPart = value.toStringAsFixed(decimals);

      // Ensure exactly 5 chars for the numeric field.
      if (numberPart.length > 5) {
        numberPart = numberPart.substring(0, 5);
        // Avoid trailing '.' if trimming lands on it.
        if (numberPart.endsWith('.')) {
          numberPart = numberPart.substring(0, 4);
        }
      } else if (pad) {
        numberPart = numberPart.padLeft(5);
      }
    }

    return '$numberPart${units[unitIndex]}';
  }

  // ///
  // void colprint(String label, String value, {int pad = 25}) {
  //   print('${label.padRight(pad)}: ${value}');
  // }
}

/// Used by [Format.row] to control the alignment of each
/// column in the table.
enum TableAlignment {
  ///
  left,

  ///
  right,

  ///
  middle
}
