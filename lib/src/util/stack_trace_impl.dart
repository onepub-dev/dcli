import 'dart:core' as core show StackTrace;
import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';

import '../settings.dart';
import 'truepath.dart';

/// Provides dart stack frame handling.
class StackTraceImpl implements core.StackTrace {
  /// You can suppress call frames from showing
  /// by specifing a non-zero value for [skipFrames]
  /// If the [workingDirectory] is provided we will output
  /// a full file path to the dart library.
  StackTraceImpl({int skipFrames = 0, String? workingDirectory})
      : _stackTrace = core.StackTrace.current,
        _skipFrames = skipFrames + 1, // always skip ourselves.
        _workingDirectory = workingDirectory;

  ///
  StackTraceImpl.fromStackTrace(this._stackTrace,
      {String? workingDirectory, int skipFrames = 0})
      : _skipFrames = skipFrames,
        _workingDirectory = workingDirectory {
    if (_stackTrace is StackTraceImpl) {
      _frames = (_stackTrace as StackTraceImpl).frames;
    }
  }

  static final _stackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');
  final core.StackTrace _stackTrace;

  /// The working directory of the project (if provided)
  final String? _workingDirectory;
  final int _skipFrames;

  List<Stackframe>? _frames;

  ///
  /// Returns a File instance for the current stackframe
  ///
  File get sourceFile => frames[0].sourceFile;

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
  int get lineNo => frames[0].lineNo;

  @override
  String toString() => formatStackTrace()!;

  /// Outputs a formatted string of the current stack_trace_nj
  /// showing upto [methodCount] methods in the trace.
  /// [methodCount] defaults to 10.

  String? formatStackTrace(
      {bool showPath = false, int methodCount = 10, int skipFrames = 0}) {
    var _skipFrames = skipFrames;
    final formatted = <String>[];
    var count = 0;

    for (final stackFrame in frames) {
      if (_skipFrames > 0) {
        _skipFrames--;
        continue;
      }
      String sourceFile;
      if (showPath) {
        sourceFile = stackFrame.sourceFile.path;
      } else {
        sourceFile = basename(stackFrame.sourceFile.path);
      }
      final newLine =
          '$sourceFile : ${stackFrame.details} : ${stackFrame.lineNo}';

      if (_workingDirectory != null) {
        formatted.add('file:///$_workingDirectory$newLine');
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

  ///
  List<Stackframe> get frames => _frames ??= _extractFrames();

  List<Stackframe> _extractFrames() {
    final lines = _stackTrace.toString().split('\n');

    // we don't want the call to StackTrace to be on the stack.
    var skipFrames = _skipFrames;

    final stackFrames = <Stackframe>[];
    for (final line in lines) {
      if (skipFrames > 0) {
        skipFrames--;
        continue;
      }
      final match = _stackTraceRegex.matchAsPrefix(line);
      if (match == null) {
        continue;
      }

      // source is one of following formats
      /// Linux
      /// file:///.../package/filename.dart:line:column
      ///
      /// Windows
      /// (file:///d:/a/dcli/dcli/bin/dcli_install.dart:line:column
      ///
      /// Package
      /// package:/package/.path./filename.dart:line:column
      ///
      final source = match.group(2)!;
      final sourceParts = source.split(':');
      var column = '0';
      var lineNo = '0';
      var sourcePath = sourceParts[1];
      if (Settings().isWindows && source.startsWith('file:')) {
        switch (sourceParts.length) {
          case 3:
            sourcePath = _getWindowsPath(sourceParts);
            break;
          case 4:
            sourcePath = _getWindowsPath(sourceParts);
            lineNo = sourceParts[3];
            break;
          case 5:
            sourcePath = _getWindowsPath(sourceParts);
            lineNo = sourceParts[3];
            column = sourceParts[4];
            break;
          default:
            sourcePath = sourceParts.join(':');
            break;
        }
      } else {
        if (sourceParts.length > 2) {
          lineNo = sourceParts[2];
        }
        if (sourceParts.length > 3) {
          column = sourceParts[3];
        }
      }

      // the actual contents of the line (sort of)
      final details = match.group(1);

      Stackframe frame;

      /// closures don't have a sourcePath.
      sourcePath = sourcePath.replaceAll('<anonymous closure>', '()');
      sourcePath = sourcePath.replaceAll('package:', '');
      // sourcePath = sourcePath.replaceFirst('<package_name>', '/lib');

      frame = Stackframe(
          File(sourcePath), int.parse(lineNo), int.parse(column), details);
      stackFrames.add(frame);
    }
    return stackFrames;
  }

  String _getWindowsPath(List<String> sourceParts) {
    final len = sourceParts[1].length;
    return '${sourceParts[1].substring(len - 1)}'
        ':${sourceParts[2]}';
  }

  /// merges two stack traces. Used when handling futures and you want
  /// combine a futures stack exception with the original calls stack
  StackTraceImpl merge(core.StackTrace microTask) {
    final _microImpl = StackTraceImpl.fromStackTrace(microTask);

    final merged = StackTraceImpl.fromStackTrace(this);

    var index = 0;
    for (final frame in _microImpl.frames) {
      // best we can do is exclude any files that are in the flutter src tree.
      if (isExcludedSource(frame)) {
        continue;
      }
      merged.frames.insert(index++, frame);
    }
    return merged;
  }
}

List<String> _excludedSource = [
  join(rootPath, 'flutter'),
  join(rootPath, 'ui'),
  join(rootPath, 'async'),
  'isolate'
];

///
bool isExcludedSource(Stackframe frame) {
  var excludeSource = false;

  final path = frame.sourceFile.absolute.path;
  for (final exclude in _excludedSource) {
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
  ///
  Stackframe(this.sourceFile, this.lineNo, this.column, this.details);

  ///
  final File sourceFile;

  ///
  final int lineNo;

  ///
  final int column;

  ///
  final String? details;
}
