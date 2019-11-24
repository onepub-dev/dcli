import 'dart:async';
import 'dart:cli';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'log.dart';
import 'script.dart';

enum _State {
  notFound,
  findHeader,
  data,
  closed,
}

///
/// Holds a representation of the virtual pubspec.yaml
/// The represntation is taken from a pubspec annotation
/// in the script.
/// TODO: provide an option to load it from the scripts
/// directory if it exists.
class PubSpec {
  final Script script;

  PubSpec(this.script);

  /// Extract the pubspec annotation from a script file
  /// and saves it to [path] as a try pubspec.yaml file.
  ///
  Future<void> saveToFile(String path) async {
    List<String> _sourceLines = _parse(script);
    final String filePath = p.join(path, "pubspec.yaml");
    final file = File(filePath);
    await file.writeAsString(_sourceLines.join('\n'));
  }

  ///
  /// Call this method to parse the pubspec annotation
  /// in a script file and return the source lines
  /// that make up the embedded pubspec.
  ///
  /// The returned lines are suitable for writting to a
  /// file based pubspec.
  List<String> _parse(Script script) {
    final file = File(script.scriptPath);

    if (!file.existsSync()) {
      throw Exception('Script file ${script.scriptPath} not found!');
    }

    List<String> sourceLines = List();
    // Read script file as lines
    final Stream<String> stream =
        file.openRead().transform(utf8.decoder).transform(LineSplitter());

    _State state = _State.notFound;

    List<String> lines = waitFor(stream.toList());

    for (String line in lines) {
      switch (state) {
        case _State.notFound:
          final String trimmed = line.trim();
          if (trimmed == r'/*') {
            state = _State.findHeader;
          } else if (trimmed == r'/* @pubspec.yaml') {
            state = _State.data;
          }
          break;
        case _State.findHeader:
          final String trimmed = line.trim();
          if (trimmed == r'@pubspec.yaml') {
            state = _State.data;
          } else {
            state = _State.notFound;
          }
          break;
        case _State.data:
          final String trimmed = line.trim();
          if (trimmed == r'*/') {
            state = _State.closed;
          } else {
            sourceLines.add(line);
          }
          break;
        case _State.closed:
          break;
      }

      if (state == _State.closed) {
        break;
      }
    }

    // Create a default pubspec as the script didn't include one.
    if (sourceLines.isEmpty) {
      Log.error(
          'dscript: Embedded pubspec not found in script. Providing default pubspec',
          LogLevel.verbose);
      sourceLines = [
        'name: ${p.basename(p.withoutExtension(script.scriptname))}'
      ];
    } else {
      Log.error('dscript: Embedded pubspec found in script', LogLevel.verbose);
    }
    return sourceLines;
  }
}
