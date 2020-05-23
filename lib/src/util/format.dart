/// provides a random collection of formatters
/// EXPERIMENTAL
///
class Format {
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
  /// If [widths] is null then a default with of 20 is used.
  ///
  /// returns a string with each of the columns padded according to the
  /// [widths].
  ///
  ///
  static String row(List<String> cols,
      {List<int> widths, List<TableAlignment> alignments, String delimiter}) {
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
          var padding = width = colwidth;
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

  // ///
  // void colprint(String label, String value, {int pad = 25}) {
  //   print('${label.padRight(pad)}: ${value}');
  // }
}

/// Used by [Format.table] to control the alignment of each
/// column in the table.
enum TableAlignment {
  ///
  left,

  ///
  right,

  ///
  middle
}
