import 'dart:convert';
import 'dart:io';

import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/my_yaml.dart';
import 'package:dshell/script/script.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/waitForEx.dart';

import 'dependencies_mixin.dart';

enum _State {
  notFound,
  findHeader,
  data,
  found,
}

///
/// Able to load and hold a representation of the @pubsec
/// annotation from a script.
class PubSpecAnnotation extends PubSpec with DependenciesMixin {
  _State state = _State.notFound;
  Script script;
  List<String> sourceLines;

  /// The pubspec loaded into a yaml representation
  MyYaml yaml;

  PubSpecAnnotation.fromScript(this.script) {
    // Read script file as lines
    List<String> lines = _readLines(File(script.path));

    sourceLines = _extractAnnotation(lines);

    yaml = MyYaml.fromString(sourceLines.join("\n"));
  }

  PubSpecAnnotation.fromString(String annotation) {
    sourceLines = _extractAnnotation(annotation.split("\n"));
  }

  /// returns true if a @pubspec annotation was found.
  bool exists() {
    return state == _State.found;
  }

  ///
  /// Call this method to parse the pubspec annotation
  /// in a script file and return the source lines
  /// that make up the embedded pubspec.
  ///
  /// The returned lines are suitable for writting to a
  /// file based pubspec.
  List<String> _extractAnnotation(List<String> lines) {
    /// Look for and load the contents of the annotated pubspec.
    /// It is of the form:
    /// /*
    /// name: script_name
    ///   dependencies:
    ///      dshell: ^1.0.0
    /// */
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
            state = _State.found;
          } else {
            sourceLines.add(line);
          }
          break;
        case _State.found:
          break;
      }

      if (state == _State.found) {
        break;
      }
    }

    if (state == _State.data) {
      throw PubSpecAnnotationException(
          "@pubspec annotation found but the closing '*/' was not seen");
    }
    return sourceLines;
  }

  ///
  /// Read the entire scipt file and return it
  /// as a list of ordered lines.
  ///
  List<String> _readLines(File file) {
    // Read script file as lines
    final Stream<String> stream =
        file.openRead().transform(utf8.decoder).transform(LineSplitter());

    List<String> lines = waitForEx(stream.toList());
    return lines;
  }
}

class PubSpecAnnotationException extends DShellException {
  PubSpecAnnotationException(String message) : super(message);
}
