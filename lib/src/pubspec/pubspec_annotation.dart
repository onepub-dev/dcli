import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../script/dependency.dart';
import '../script/script.dart';
import '../util/dcli_exception.dart';
import '../util/wait_for_ex.dart';
import 'pubspec.dart';

enum _State {
  notFound,
  findHeader,
  content,
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
  /// If we are compiled then you can't get the annotation.
  PubSpecAnnotation.fromScript(this._script) {
    /// If we have been compiled then we can't get access to the annotation.
    /// A compiled script won't end in .dart.
    if (!_script.isCompiled) {
      // Read script file as lines
      var lines = _readLines(File(_script.path));

      var sourceLines = _extractAnnotation(lines);

      if (sourceLines.isNotEmpty) {
        _pubspec = PubSpecImpl.fromString(sourceLines.join('\n'));
      }
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
    ///      dcli: ^0.20.0
    /// */
    ///

    var dataLines = <String>[];
    for (var line in lines) {
      switch (state) {
        case _State.notFound:
          final trimmed = line.trim();
          if (_isCommentStart(trimmed)) {
            state = _State.findHeader;
            // check if the comment start also contains a pubspec.
            if (_hasPubspecStart(trimmed)) {
              state = _State.content;
            }
          }
          break;
        case _State.findHeader:
          final trimmed = line.trim();
          if (_hasPubspecStart(trimmed)) {
            state = _State.content;
          } else if (_isCommentEnd(trimmed)) {
            state = _State.notFound;
          }
          break;
        case _State.content:
          final trimmed = line.trim();
          if (_isCommentEnd(trimmed)) {
            state = _State.found;
          } else {
            /// remove leading comment characters
            /// e.g.
            /// ** name:xxx
            /// becomes
            /// name:xxx
            line = _stripComment(line);
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

    if (state == _State.content) {
      throw PubSpecAnnotationException("@pubspec annotation found but the closing '*/' was not seen");
    }
    return dataLines;
  }

  ///
  /// Read the entire scipt file and return it
  /// as a list of ordered lines.
  ///
  List<String> _readLines(File file) {
    // Read script file as lines
    final stream = file.openRead().transform(utf8.decoder).transform(LineSplitter());

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

  static bool _hasPubspecStart(String line) {
    return (line.contains(r'@pubspec') || line.contains(r'@pubspec.yaml'));
  }

  /// Strips leading C style comments off a line.
  static String _stripComment(String line) {
    // remove leading comment characters '*' or '**'
    return line.replaceAll(RegExp(r'^\s+\*+'), '');
  }

  static bool _isCommentStart(String trimmed) {
    return trimmed.startsWith(r'/*') || trimmed.startsWith(r'/**');
  }

  static bool _isCommentEnd(String trimmed) {
    return trimmed.endsWith(r'*/') || trimmed.endsWith(r'**/');
  }
}

/// Throw if we encounter an error reading an annotation.
class PubSpecAnnotationException extends DCliException {
  /// Throw if we encounter an error reading an annotation.
  PubSpecAnnotationException(String message) : super(message);
}
