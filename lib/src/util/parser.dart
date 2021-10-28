import 'dart:convert' as convert;
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dcli_core/dcli_core.dart';

import 'package:ini/ini.dart';

import 'package:yaml/yaml.dart';

/// Provides parsers for a number of common file formats.
///
class Parser {
  /// Creates a Parser with a set of lines that will be interpreted
  /// as a selected file type.
  /// The parser may only be used once.
  Parser(this._lines);

  final List<String?> _lines;

  ///
  /// Interprets the read lines as JSON strings and builds
  /// the corresponding objects.
  ///
  /// See: https://api.flutter.dev/flutter/dart-convert/JsonDecoder-class.html
  dynamic jsonDecode() => convert.jsonDecode(_lines.join('\n'));

  /// Loads a single document from a YAML string.
  ///
  /// If the string contains more than one document, this throws a
  /// [YamlException]. In future releases, this will become an [ArgumentError].
  ///
  /// The return value is mostly normal Dart objects. However,
  /// since YAML mappings
  /// support some key types that the default Dart map implementation doesn't
  /// (NaN, lists, and maps), all maps in the returned document are [YamlMap]s.
  /// These have a few small behavioral differences from the default Map
  /// implementation; for details, see the [YamlMap] class.
  ///
  /// In future versions, maps will instead be HashMaps with a custom equality
  /// operation.
  dynamic yamlDecode() => loadYaml(_lines.join('\n'));

  /// Interprets the read lines as a csv file.
  ///
  /// Returns a list of rows each containing a list
  /// of columns.
  ///
  /// See: https://pub.dev/packages/csv
  List<List<dynamic>> csvDecode() =>
      CsvToListConverter(eol: Platform().eol, shouldParseNumbers: false)
          .convert(_lines.join('\n'));

  /// Interprets the read lines as an ini file.
  /// See https://pub.dev/packages/ini
  Config iniDecode() => Config.fromStrings(_lines as List<String>);
}
