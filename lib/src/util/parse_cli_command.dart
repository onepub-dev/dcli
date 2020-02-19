import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/script/command_line_runner.dart';
import 'package:glob/glob.dart';

/// Class to parse a OS command, contained in a string, which we need to pass
/// into the dart Process.start method as a application name and a series
/// of arguments.
class ParsedCliCommand {
  String cmd;
  var args = <String>[];

  ParsedCliCommand(String command) {
    var qargs = parse(command);
    args = expandGlobs(qargs);

    if (Settings().isVerbose) {
      Settings().verbose('CWD: ${Directory.current}');
      Settings().verbose('Parsed results cmd: $cmd args: $args');
    }
  }

  ParsedCliCommand.fromParsed(this.cmd, List<String> args) {
    var qargs = _QArg.translate(args);
    args = expandGlobs(qargs);

    if (Settings().isVerbose) {
      Settings().verbose('CWD: ${Directory.current}');
      Settings().verbose('Parsed results cmd: $cmd args: $args');
    }
  }

  List<_QArg> parse(String command) {
    var parts = <_QArg>[];

    var state = ParseState.STARTING;

    // if try the next character should be escaped.
    // var escapeNext = false;

    // when we find a quote this will be storing
    // the quote char (' or ") that we are looking for.

    String matchingQuote;
    var currentPart = '';

    for (var i = 0; i < command.length; i++) {
      var char = command[i];

      switch (state) {
        case ParseState.STARTING:
          // ignore leading space.
          if (char == ' ') {
            break;
          }
          if (char == '"') {
            state = ParseState.IN_QUOTE;
            matchingQuote = '"';
            break;
          }
          if (char == "'") {
            state = ParseState.IN_QUOTE;
            matchingQuote = "'";
            break;
          }
          // if (char == '\\') {
          //   //escapeNext = true;
          // }

          currentPart += char;
          state = ParseState.IN_WORD;

          break;

        case ParseState.IN_WORD:
          if (char == ' ') // && !escapeNext)
          {
            //escapeNext = false;
            // a non-escape space means a new part.
            state = ParseState.STARTING;
            parts.add(_QArg(currentPart));
            currentPart = '';
            break;
          }

          if (char == '"' || char == "'") {
            state = ParseState.IN_QUOTE;
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

        case ParseState.IN_QUOTE:
          if (char == matchingQuote) {
            state = ParseState.STARTING;
            parts.add(_QArg.fromParsed(currentPart, true));
            currentPart = '';
            break;
          }

          currentPart += char;
          break;
      }
    }

    if (currentPart.isNotEmpty) {
      parts.add(_QArg.fromParsed(currentPart, false));
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
  List<String> expandGlobs(List<_QArg> qargs) {
    var expanded = <String>[];

    for (var qarg in qargs) {
      if (qarg.wasQuoted) {
        expanded.add(qarg.arg);
      } else {
        expanded.addAll(expandGlob(qarg));
      }
    }
    return expanded;
  }

  Iterable<String> expandGlob(_QArg qarg) {
    var glob = Glob(qarg.arg);

    var files = glob.listSync();

    if (files.isEmpty) {
      // if no matches the bash spec says return
      // the original arg.
      return [qarg.arg];
    } else {
      return files.map((f) => f.path);
    }
  }
}

enum ParseState { STARTING, IN_QUOTE, IN_WORD }

class _QArg {
  bool wasQuoted;
  String arg;

  _QArg.fromParsed(this.arg, this.wasQuoted);

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

  static List<_QArg> translate(List<String> args) {
    var qargs = <_QArg>[];
    for (var arg in args) {
      var qarg = _QArg(arg);
      qargs.add(qarg);
    }
    return qargs;
  }
}
