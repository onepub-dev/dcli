/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'dart:math';

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
          break;
        case TableAlignment.right:
          row += col.padLeft(width);
          break;
        case TableAlignment.middle:
          final padding = width = colwidth;
          row += col.padLeft(padding);
          break;
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
  /// var long = 'http://www.noojee.com.au/some/long/url';
  /// print(limitString(long, width: 20))
  /// > http://...ong/url
  String limitString(String display, {int width = 40}) {
    if (display.length <= width) {
      return display;
    }
    final elipses = width <= 2 ? 1 : 3;
    final partLength = (width - elipses) ~/ 2;
    // ignore: lines_longer_than_80_chars
    return '${display.substring(0, partLength)}${'.' * elipses}${display.substring(display.length - partLength)}';
  }

  /// returns a double as a percentage to the given [precision]
  /// e.g. 0.11 becomes 11% if [precision] is 0.
  String percentage(double progress, int precision) =>
      '${(progress * 100).toStringAsFixed(precision)}%';

  /// returns the the number of [bytes] in a human readable
  /// form. e.g. 1e+5 3.000T, 10.00G, 100.0M, 20.00K, 10B
  ///
  /// Except for absurdly large no. (> 10^20)
  /// the return is guarenteed to be 6 characters long.
  /// For no. < 1000K we right pad the no. with spaces.
  String bytesAsReadable(int bytes, {bool pad = true}) {
    String human;

    if (bytes < 1000) {
      human = _fiveDigits(bytes, 0, 'B', pad: pad);
    } else if (bytes < 1000000) {
      human = _fiveDigits(bytes, 3, 'K', pad: pad);
    } else if (bytes < 1000000000) {
      human = _fiveDigits(bytes, 6, 'M', pad: pad);
    } else if (bytes < 1000000000000) {
      human = _fiveDigits(bytes, 9, 'G', pad: pad);
    } else if (bytes < 1000000000000000) {
      human = _fiveDigits(bytes, 12, 'T', pad: pad);
    } else {
      human = bytes.toStringAsExponential(0);
    }
    return human;
  }

  String _fiveDigits(int bytes, int exponent, String letter,
      {bool pad = true}) {
    final num result;
    String human;
    if (bytes < 1000) {
      // less than 1K we display integers only
      result = bytes ~/ pow(10, exponent);
      human = '$result'.padLeft(pad ? 5 : 0);
    } else {
      // greater than 1K we display decimals
      result = bytes / pow(10, exponent);
      human = '$result';

      if (human.length > 5) {
        human = human.substring(0, 5);
      } else {
        /// add trailing zeros to maintain a fixed width of 5 chars.
        if (pad) {
          human = human.padRight(5, '0');
        }
      }
    }

    return '$human$letter';
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
