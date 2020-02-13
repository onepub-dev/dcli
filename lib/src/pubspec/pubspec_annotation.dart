import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import 'pubspec.dart';
import '../script/dependency.dart';
import '../script/script.dart';
import '../util/dshell_exception.dart';
import '../util/waitForEx.dart';

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
  PubSpec pubspec;
  Script script;

  PubSpecAnnotation.fromScript(this.script) {
    // Read script file as lines
    var lines = _readLines(File(script.path));

    var sourceLines = _extractAnnotation(lines);

    if (sourceLines.isNotEmpty) {
      pubspec = PubSpecImpl.fromString(sourceLines.join('\n'));
    }
  }

  PubSpecAnnotation.fromString(String annotation) {
    var sourceLines = _extractAnnotation(annotation.split('\n'));

    pubspec = PubSpecImpl.fromString(sourceLines.join('\n'));
  }

  /// returns true if a @pubspec annotation was found.
  bool annotationFound() {
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
    var state = _State.notFound;

    /// Look for and load the contents of the annotated pubspec.
    /// It is of the form:
    /// /*
    /// name: script_name
    ///   dependencies:
    ///      dshell: ^1.0.0
    /// */
    ///

    var dataLines = <String>[];
    for (var line in lines) {
      switch (state) {
        case _State.notFound:
          final trimmed = line.trim();
          if (trimmed == r'/*') {
            state = _State.findHeader;
          } else if (isStart(trimmed)) {
            state = _State.data;
          }
          break;
        case _State.findHeader:
          final trimmed = line.trim();
          if (isAtPubSpec(trimmed)) {
            state = _State.data;
          } else {
            state = _State.notFound;
          }
          break;
        case _State.data:
          final trimmed = line.trim();
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
    final stream =
        file.openRead().transform(utf8.decoder).transform(LineSplitter());

    var lines = waitForEx(stream.toList());
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
  Version get version => pubspec.version;

  @override
  set version(Version version) => pubspec.version = version;

  @override
  void writeToFile(String path) {
    pubspec.writeToFile(path);
  }

  static bool isStart(String line) {
    var compressed = line.replaceAll(RegExp(r'\s'), '');

    return (compressed == r'/*@pubspec' || compressed == r'/*@pubspec.yaml');
  }

  static bool isAtPubSpec(String trimmed) {
    return (trimmed == r'@pubspec' || trimmed == r'@pubspec.yaml');
  }
}

class PubSpecAnnotationException extends DShellException {
  PubSpecAnnotationException(String message) : super(message);
}
