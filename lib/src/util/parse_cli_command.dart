import 'dart:io';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import '../../dshell.dart';
import '../script/command_line_runner.dart';

/// Class to parse a OS command, contained in a string, which we need to pass
/// into the dart Process.start method as a application name and a series
/// of arguments.
class ParsedCliCommand {
  /// The commdand that we parsed from the command line
  String cmd;

  /// The args that we parsed from the command line
  List<String> args = <String>[];

  ///
  ParsedCliCommand(String command, String workingDirectory) {
    var qargs = _parse(command);
    args = expandGlobs(qargs, workingDirectory);

    if (Settings().isVerbose) {
      Settings().verbose('CWD: ${Directory.current}');
      Settings().verbose('Parsed results cmd: $cmd args: $args');
    }
  }

  /// when passed individual args we respect any quotes that are
  /// passed as they have been put there with intent.
  ParsedCliCommand.fromParsed(
      this.cmd, List<String> rawArgs, String workingDirectory) {
    var qargs = _QArg.translate(rawArgs);
    args = expandGlobs(qargs, workingDirectory);

    if (Settings().isVerbose) {
      Settings().verbose('CWD: ${Directory.current}');
      Settings().verbose('Parsed results cmd: $cmd args: $args');
    }
  }

  /// parses the given command breaking them done into words
  List<_QArg> _parse(String commandLine) {
    var parts = <_QArg>[];

    var state = _ParseState.starting;

    // if try the next character should be escaped.
    // var escapeNext = false;

    // when we find a quote this will be storing
    // the quote char (' or ") that we are looking for.

    String matchingQuote;
    var currentPart = '';

    for (var i = 0; i < commandLine.length; i++) {
      var char = commandLine[i];

      switch (state) {
        case _ParseState.starting:
          // ignore leading space.
          if (char == ' ') {
            break;
          }
          if (char == '"') {
            state = _ParseState.inQuote;
            matchingQuote = '"';
            break;
          }
          if (char == "'") {
            state = _ParseState.inQuote;
            matchingQuote = "'";
            break;
          }
          // if (char == '\\') {
          //   //escapeNext = true;
          // }

          currentPart += char;
          state = _ParseState.inWord;

          break;

        case _ParseState.inWord:
          if (char == ' ') // && !escapeNext)
          {
            //escapeNext = false;
            // a non-escape space means a new part.
            state = _ParseState.starting;
            parts.add(_QArg(currentPart));
            currentPart = '';
            break;
          }

          if (char == '"' || char == "'") {
            state = _ParseState.inQuote;
            matchingQuote = char;
            break;
            //             throw InvalidArguments(
            //                 '''A command argument may not have a quote in the middle of a word.
            // Command: $command
            // ${' '.padRight(9 + i)}^''');
          }

          // if (char == '\\' && !escapeNext) {
          //   escapeNext = true;
          // } else {
          //   escapeNext = false;
          // }
          currentPart += char;
          break;

        case _ParseState.inQuote:
          if (char == matchingQuote) {
            state = _ParseState.starting;
            parts.add(_QArg.fromParsed(currentPart, wasQuoted: true));
            currentPart = '';
            break;
          }

          currentPart += char;
          break;
      }
    }

    if (currentPart.isNotEmpty) {
      parts.add(_QArg.fromParsed(currentPart, wasQuoted: false));
    }

    if (parts.isEmpty) {
      throw InvalidArguments('The string did not contain a command.');
    }
    cmd = parts[0].arg;

    if (parts.length > 1) {
      return parts.sublist(1);
    } else {
      return <_QArg>[];
    }
  }

  ///
  /// to emulate bash and support what most cli apps support we expand
  /// globs.
  /// Any argument that contains *, ? or [ will
  /// be expanded.
  /// See https://github.com/bsutton/dshell/issues/56
  ///
  List<String> expandGlobs(List<_QArg> qargs, String workingDirectory) {
    var expanded = <String>[];

    for (var qarg in qargs) {
      if (qarg.wasQuoted) {
        expanded.add(qarg.arg);
      } else {
        expanded.addAll(qarg.expandGlob(workingDirectory));
      }
    }
    return expanded;
  }
}

enum _ParseState { starting, inQuote, inWord }

class _QArg {
  bool wasQuoted;
  String arg;

  _QArg.fromParsed(this.arg, {@required this.wasQuoted});

  _QArg(String iarg) {
    wasQuoted = false;
    arg = iarg.trim();

    if (arg.startsWith('"') && arg.endsWith('"')) {
      wasQuoted = true;
    }
    if (arg.startsWith("'") && arg.endsWith("'")) {
      wasQuoted = true;
    }

    if (wasQuoted) {
      arg = arg.substring(1, arg.length - 1);
    }
  }

  /// We only do glob expansion if the arg contains at least one of
  /// *, [, ?
  ///
  /// Note: under Windows powershell does perform glob expansion so we need
  /// to supress glob expansion.
  bool get needsExpansion {
    return !Platform.isWindows &&
        (arg.contains('*') || arg.contains('[') || arg.contains('?'));
  }

  static List<_QArg> translate(List<String> args) {
    var qargs = <_QArg>[];
    for (var arg in args) {
      var qarg = _QArg(arg);
      qargs.add(qarg);
    }
    return qargs;
  }

  Iterable<String> expandGlob(String workingDirectory) {
    var expanded = <String>[];
    if (arg.contains('~')) {
      arg = arg.replaceAll('~', HOME);
    }
    if (needsExpansion) {
      expanded.addAll(_expandGlob(workingDirectory));
    } else {
      expanded.add(arg);
    }
    return expanded;
  }

  Iterable<String> _expandGlob(String workingDirectory) {
    var glob = Glob(arg);

    var files = <FileSystemEntity>[];
    try {
      files = glob.listSync(root: workingDirectory);
    } on FileSystemException {
      files = [];
    }

    if (files.isEmpty) {
      // if no matches the bash spec says return
      // the original arg.
      return [arg];
    } else {
      return files
          .where((f) => !isHidden(workingDirectory, f))
          .map((f) => f.path);
    }
  }

  // check if the entity is a hidden file (.xxx) or
  // if lives in a hidden directory.
  bool isHidden(String root, FileSystemEntity entity) {
    var relativePath = truepath(relative(entity.path, from: root));

    var parts = relativePath.split(separator);

    var isHidden = false;
    for (var part in parts) {
      if (part.startsWith('.')) {
        isHidden = true;
        break;
      }
    }
    return isHidden;
  }
}
