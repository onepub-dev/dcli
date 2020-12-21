import 'dart:io';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import '../../dcli.dart';
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
    workingDirectory ??= pwd;
    if (!exists(workingDirectory)) {
      throw RunException(command, -1,
          "The workingDirectory ${truepath(workingDirectory)} doesn't exists.");
    }
    final qargs = _parse(command);
    args = expandGlobs(qargs, workingDirectory);
  }

  /// when passed individual args we respect any quotes that are
  /// passed as they have been put there with intent.
  ParsedCliCommand.fromParsed(
      this.cmd, List<String> rawArgs, String workingDirectory) {
    workingDirectory ??= pwd;
    if (!exists(workingDirectory)) {
      throw RunException('$cmd ${rawArgs.join(' ')}', -1,
          "The workingDirectory ${truepath(workingDirectory)} doesn't exists.");
    }

    final qargs = _QArg.translate(rawArgs);
    args = expandGlobs(qargs, workingDirectory);
  }

  /// parses the given command breaking them done into words
  List<_QArg> _parse(String commandLine) {
    final parts = <_QArg>[];

    var state = _ParseState.starting;

    // if try the next character should be escaped.
    // var escapeNext = false;

    // when we find a quote this will be storing
    // the quote char (' or ") that we are looking for.

    String matchingQuote;
    var currentPart = '';

    for (var i = 0; i < commandLine.length; i++) {
      final char = commandLine[i];

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
          // added ignore as lint has a bug for conditional in a switch statement #27
          // ignore: invariant_booleans
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
  /// See https://github.com/bsutton/dcli/issues/56
  ///
  List<String> expandGlobs(List<_QArg> qargs, String workingDirectory) {
    final expanded = <String>[];

    for (final qarg in qargs) {
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

  _QArg.fromParsed(this.arg, {@required this.wasQuoted});

  /// We only do glob expansion if the arg contains at least one of
  /// *, [, ?
  ///
  /// Note: under Windows powershell does perform glob expansion so we need
  /// to supress glob expansion.
  bool get needsExpansion {
    return !Settings().isWindows &&
        (arg.contains('*') || arg.contains('[') || arg.contains('?'));
  }

  static List<_QArg> translate(List<String> args) {
    final qargs = <_QArg>[];
    for (final arg in args) {
      final qarg = _QArg(arg);
      qargs.add(qarg);
    }
    return qargs;
  }

  Iterable<String> expandGlob(String workingDirectory) {
    final expanded = <String>[];
    if (arg.contains('~')) {
      arg = arg.replaceAll('~', HOME);
    }
    if (needsExpansion) {
      final files = _expandGlob(workingDirectory);

      /// translate the files to relative paths if appropriate.
      for (var file in files) {
        if (isWithin(workingDirectory, file)) {
          file = relative(file, from: workingDirectory);
        }
        expanded.add(file);
      }
    } else {
      expanded.add(arg);
    }
    return expanded;
  }

  Iterable<String> _expandGlob(String workingDirectory) {
    final glob = Glob(arg);

    /// we are interested in the last part of the arg.
    /// e.g. of  path/.* we want the .*
    final includeHidden = basename(arg).startsWith('.');

    var files = <FileSystemEntity>[];

    files = glob.listSync(root: workingDirectory);

    if (files.isEmpty) {
      // if no matches the bash spec says return
      // the original arg.
      return [arg];
    } else {
      return files
          .where((f) => includeHidden || !isHidden(workingDirectory, f))
          .map((f) => f.path);
    }
  }

  // check if the entity is a hidden file (.xxx) or
  // if lives in a hidden directory.
  bool isHidden(String root, FileSystemEntity entity) {
    final relativePath = truepath(relative(entity.path, from: root));

    final parts = relativePath.split(separator);

    var isHidden = false;
    for (final part in parts) {
      if (part.startsWith('.')) {
        isHidden = true;
        break;
      }
    }
    return isHidden;
  }
}
