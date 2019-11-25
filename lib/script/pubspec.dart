import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dshell/util/waitForEx.dart';
import 'package:dshell/util/file_helper.dart';
import 'package:path/path.dart' as p;
import 'std_log.dart';
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

  /// If necessary, extract the pubspec annotation from a script file
  /// and saves it to [path] as a pubspec.yaml file.
  ///
  /// Returns true if if the pubspec.yaml has changed
  /// indicating that a 'pub get' needs to be run.
  ///
  bool saveToFile(String path) {
    final String pubSpecPath = p.join(path, "pubspec.yaml");

    final file = File(pubSpecPath);

    bool pubExists = exists(pubSpecPath);
    DateTime scriptModified = lastModified(script.path);
    // If the script hasn't changed since we last
    // updated the pubspec then we don't need to run pub get.
    if (pubExists) {
      DateTime pubSpecModified = lastModified(pubSpecPath);
      if (scriptModified == pubSpecModified) {
        return false;
      }
    }

    // read the pubspec from the script
    List<String> _scriptPubSpecLines = _parse(script);

    if (pubExists) {
      // The lastModified dates don't match so we need
      // to check the actual contents.
      // If the lines in the pubspec are identical we also
      // don't need to run pub get
      List<String> pubSpecLines = _read(file);

      if (ListEquality<String>().equals(pubSpecLines, _scriptPubSpecLines)) {
        return false;
      }
    }

    waitForEx<void>(file.writeAsString(_scriptPubSpecLines.join('\n') + "\n"));
    // set the last modified on the pubspec to match the script
    // so we can detect future changes.
    setLastModifed(pubSpecPath, scriptModified);

    // pub get required.
    return true;
  }

  /// reads the contents of the pubsec and
  /// returns a list of lines.
  List<String> _read(File filePubSpec) {
    String source = waitForEx<String>(filePubSpec.readAsString());

    List<String> lines = source.split("\n");
    return lines;
  }

  ///
  /// Call this method to parse the pubspec annotation
  /// in a script file and return the source lines
  /// that make up the embedded pubspec.
  ///
  /// The returned lines are suitable for writting to a
  /// file based pubspec.
  List<String> _parse(Script script) {
    final file = File(script.path);

    if (!file.existsSync()) {
      throw Exception('Script file ${script.path} not found!');
    }

    List<String> sourceLines = List();
    // Read script file as lines
    final Stream<String> stream =
        file.openRead().transform(utf8.decoder).transform(LineSplitter());

    _State state = _State.notFound;

    List<String> lines = waitForEx(stream.toList());

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
      StdLog.stderr(
          'dscript: Embedded pubspec not found in script. Providing default pubspec',
          LogLevel.verbose);
      sourceLines = [
        'name: ${p.basename(p.withoutExtension(script.scriptname))}'
      ];
    } else {
      StdLog.stderr(
          'dscript: Embedded pubspec found in script', LogLevel.verbose);
    }
    return sourceLines;
  }
}
