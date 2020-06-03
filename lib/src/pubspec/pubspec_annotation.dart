import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../script/dependency.dart';
import '../script/script.dart';
import '../util/dshell_exception.dart';
import '../util/wait_for_ex.dart';
import 'pubspec.dart';

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
  PubSpec _pubspec;
  Script _script;

  /// creates an annotation by reading it from a dart script.
  PubSpecAnnotation.fromScript(this._script) {
    // Read script file as lines
    var lines = _readLines(File(_script.path));

    var sourceLines = _extractAnnotation(lines);

    if (sourceLines.isNotEmpty) {
      _pubspec = PubSpecImpl.fromString(sourceLines.join('\n'));
    }
  }

  /// creates an annotation by reading it from a string.
  PubSpecAnnotation.fromString(String annotation) {
    var sourceLines = _extractAnnotation(annotation.split('\n'));

    _pubspec = PubSpecImpl.fromString(sourceLines.join('\n'));
  }

  /// returns true if a @pubspec annotation was found.
  bool annotationFound() {
    return _pubspec != null;
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
          } else if (_isStart(trimmed)) {
            state = _State.data;
          }
          break;
        case _State.findHeader:
          final trimmed = line.trim();
          if (_isAtPubSpec(trimmed)) {
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
    _pubspec.dependencies = newDependencies;
  }

  @override
  List<Dependency> get dependencies => _pubspec.dependencies;

  @override
  String get name => _pubspec.name;

  @override
  Version get version => _pubspec.version;

  @override
  set version(Version version) => _pubspec.version = version;

  @override
  void saveToFile(String path) {
    _pubspec.saveToFile(path);
  }

  static bool _isStart(String line) {
    var compressed = line.replaceAll(RegExp(r'\s'), '');

    return (compressed == r'/*@pubspec' || compressed == r'/*@pubspec.yaml');
  }

  static bool _isAtPubSpec(String trimmed) {
    return (trimmed == r'@pubspec' || trimmed == r'@pubspec.yaml');
  }
}

/// Throw if we encounter an error reading an annotation.
class PubSpecAnnotationException extends DShellException {
  /// Throw if we encounter an error reading an annotation.
  PubSpecAnnotationException(String message) : super(message);
}
