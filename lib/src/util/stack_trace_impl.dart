import 'dart:core' as core show StackTrace;
import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';

import '../settings.dart';

class StackTraceImpl implements core.StackTrace {
  static final stackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');
  final core.StackTrace stackTrace;

  final String workingDirectory;
  final int _skipFrames;

  List<Stackframe> _frames;

  /// You can suppress call frames from showing
  /// by specifing a non-zero value for [skipFrames]
  /// If the workingDirectory is provided we will output
  /// a full file path to the dart library.
  StackTraceImpl({int skipFrames = 0, this.workingDirectory})
      : stackTrace = core.StackTrace.current,
        _skipFrames = skipFrames + 1; // always skip ourselves.

  StackTraceImpl.fromStackTrace(core.StackTrace stackTrace,
      {this.workingDirectory, int skipFrames = 0})
      : stackTrace = stackTrace,
        _skipFrames = skipFrames {
    if (stackTrace is StackTraceImpl) {
      _frames = stackTrace.frames;
    }
  }

  ///
  /// Returns a File instance for the current stackframe
  ///
  File get sourceFile {
    return frames[0].sourceFile;
  }

  ///
  /// Returns the Filename for the current stackframe
  ///
  String get sourceFilename => basename(sourcePath);

  ///
  /// returns the full path for the current stackframe file
  ///
  String get sourcePath => sourceFile.path;

  ///
  /// Returns the filename for the current stackframe
  ///
  int get lineNo {
    return frames[0].lineNo;
  }

  @override
  String toString() {
    return formatStackTrace();
  }

  /// Outputs a formatted string of the current stack_trace_nj
  /// showing upto [methodCount] methods in the trace.
  /// [methodCount] defaults to 10.

  String formatStackTrace(
      {bool showPath = false, int methodCount = 10, int skipFrames = 0}) {
    var formatted = <String>[];
    var count = 0;

    for (var stackFrame in frames) {
      if (skipFrames > 0) {
        skipFrames--;
        continue;
      }
      String sourceFile;
      if (showPath) {
        sourceFile = stackFrame.sourceFile.path;
      } else {
        sourceFile = basename(stackFrame.sourceFile.path);
      }
      var newLine =
          ('${sourceFile} : ${stackFrame.details} : ${stackFrame.lineNo}');

      if (workingDirectory != null) {
        formatted.add('file:///' + workingDirectory + newLine);
      } else {
        formatted.add(newLine);
      }
      if (++count == methodCount) {
        break;
      }
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  List<Stackframe> get frames {
    _frames ??= _extractFrames();
    return _frames;
  }

  List<Stackframe> _extractFrames() {
    var lines = stackTrace.toString().split('\n');

    // we don't want the call to StackTrace to be on the stack.
    var skipFrames = _skipFrames;

    var stackFrames = <Stackframe>[];
    for (var line in lines) {
      if (skipFrames > 0) {
        skipFrames--;
        continue;
      }
      var match = stackTraceRegex.matchAsPrefix(line);
      if (match == null) continue;

      // source is one of two formats
      // file:///.../package/filename.dart:column:line
      // package:/package/.path./filename.dart:column:line
      var source = match.group(2);
      var sourceParts = source.split(':');

      // deal with paths that contain c:\
      var argOffset = sourceParts.length == 5 && Settings().isWindows ? 1 : 0;

      ArgumentError.value(sourceParts.length == 4 + argOffset,
          "Stackframe source does not contain the expeted no of colons '$source'");

      var column = '0';
      var lineNo = '0';
      var sourcePath = sourceParts[1 + argOffset];
      if (sourceParts.length > (2  + argOffset)) {
        lineNo = sourceParts[2 + argOffset];
      }
      if (sourceParts.length > (3 + argOffset)) {
        column = sourceParts[3 + argOffset];
      }

      // the actual contents of the line (sort of)
      var details = match.group(1);

      sourcePath = sourcePath.replaceAll('<anonymous closure>', '()');
      sourcePath = sourcePath.replaceAll('package:', '');
      // sourcePath = sourcePath.replaceFirst('<package_name>', '/lib');

      var frame = Stackframe(
          File(sourcePath), int.parse(lineNo), int.parse(column), details);
      stackFrames.add(frame);
    }
    return stackFrames;
  }

  StackTraceImpl merge(core.StackTrace microTask) {
    var _microImpl = StackTraceImpl.fromStackTrace(microTask);

    var merged = StackTraceImpl.fromStackTrace(this);

    var index = 0;
    for (var frame in _microImpl.frames) {
      // best we can do is exclude any files that are in the flutter src tree.
      if (isExcludedSource(frame)) {
        continue;
      }
      merged.frames.insert(index++, frame);
    }
    return merged;
  }
}

List<String> excludedSource = ['/flutter', '/ui', '/async', 'isolate'];
bool isExcludedSource(Stackframe frame) {
  var excludeSource = false;

  var path = frame.sourceFile.absolute.path;
  for (var exclude in excludedSource) {
    if (path.startsWith(exclude)) {
      excludeSource = true;
      break;
    }
  }
  return excludeSource;
}

///
/// A single frame from a stack trace.
/// Holds the sourceFile name and line no.
///
class Stackframe {
  final File sourceFile;
  final int lineNo;
  final int column;
  final String details;

  Stackframe(this.sourceFile, this.lineNo, this.column, this.details);
}
