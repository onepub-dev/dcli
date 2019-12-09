import 'dart:convert';
import 'dart:io';

import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/script.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/waitForEx.dart';

enum _State {
  notFound,
  findHeader,
  data,
  found,
}

///
/// Able to load and hold a representation of the @pubsec
/// annotation from a script.
class PubSpecAnnotation implements PubSpec // with DependenciesMixin
{
  PubSpecImpl pubspec;
  Script script;

  PubSpecAnnotation.fromScript(this.script) {
    // Read script file as lines
    List<String> lines = _readLines(File(script.path));

    List<String> sourceLines = _extractAnnotation(lines);

    if (sourceLines.isNotEmpty) {
      pubspec = PubSpecImpl.fromString(sourceLines.join("\n"));
    }
  }

  PubSpecAnnotation.fromString(String annotation) {
    List<String> sourceLines = _extractAnnotation(annotation.split("\n"));

    pubspec = PubSpecImpl.fromString(sourceLines.join("\n"));
  }

  /// returns true if a @pubspec annotation was found.
  bool exists() {
    return pubspec != null;
  }

  ///
  /// Call this method to parse the pubspec annotation
  /// in a script file and return the source lines
  /// that make up the embedded pubspec.
  ///
  /// The returned lines are suitable for writting to a
  /// file based pubspec.
  static List<String> _extractAnnotation(List<String> lines) {
    _State state = _State.notFound;

    /// Look for and load the contents of the annotated pubspec.
    /// It is of the form:
    /// /*
    /// name: script_name
    ///   dependencies:
    ///      dshell: ^1.0.0
    /// */
    ///

    List<String> dataLines = List();
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
            dataLines.add(line);
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
    return dataLines;
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

  @override
  set dependencies(List<Dependency> newDependencies) {
    pubspec.dependencies = newDependencies;
  }

  @override
  List<Dependency> get dependencies => pubspec.dependencies;

  @override
  String get name => pubspec.name;

  @override
  String get version => pubspec.version;

  @override
  void writeToFile(String path) {
    pubspec.writeToFile(path);
  }
}

class PubSpecAnnotationException extends DShellException {
  PubSpecAnnotationException(String message) : super(message);
}
