/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

import '../../dcli.dart';
import 'enum_helper.dart';

/// Class to parse a OS command, contained in a string, which we need to pass
/// into the dart Process.start method as a application name and a series
/// of arguments.
class ParsedCliCommand {
  /// The commdand that we parsed from the command line
  late String cmd;

  /// The args that we parsed from the command line
  var args = <String>[];

  /// The escape character use for command lines
  static const escapeCharacter = '^';

  ///
  /// Throws [RunException].
  ParsedCliCommand(String command, String? workingDirectory) {
    workingDirectory ??= pwd;
    if (!exists(workingDirectory)) {
      throw RunException(
        command,
        -1,
        "The workingDirectory ${truepath(workingDirectory)} doesn't exists.",
      );
    }
    final qargs = _parse(command);
    args = _expandGlobs(qargs, workingDirectory);
  }

  /// when passed individual args we respect any quotes that are
  /// passed as they have been put there with intent.
  /// Throws [RunException].
  ParsedCliCommand.fromParsed(
    this.cmd,
    List<String> rawArgs,
    String? workingDirectory,
  ) {
    workingDirectory ??= pwd;
    if (!exists(workingDirectory)) {
      throw RunException(
        '$cmd ${rawArgs.join(' ')}',
        -1,
        "The workingDirectory ${truepath(workingDirectory)} doesn't exists.",
      );
    }

    final qargs = _QArg.translate(rawArgs);
    args = _expandGlobs(qargs, workingDirectory);
  }

  /// parses the given command breaking them done into words
  /// Throws [InvalidArgumentException].
  List<_QArg> _parse(String commandLine) {
    final parts = <_QArg>[];

    /// The stack helps us deal with nest quotes.
    final stateStack = StackList<_ParseFrame>();
    var currentState = _ParseFrame(_ParseState.searching, -1);

    /// The current word we are adding characters to.
    var currentWord = '';

    for (var i = 0; i < commandLine.length; i++) {
      final char = commandLine[i];

      switch (currentState.state) {
        case _ParseState.searching:
          // ignore leading space.
          if (char == ' ') {
            break;
          }

          /// single or double quote puts us into inQuote mode
          if (char == '"' || char == "'") {
            stateStack.push(currentState);
            currentState = _ParseFrame.forQuote(stateStack, i, char);
            break;
          }

          /// ^ is our escape character.
          /// Put us into escape mode to escape the next character.
          if (char == escapeCharacter) {
            stateStack.push(currentState);
            currentState = _ParseFrame(_ParseState.escaped, i);
            break;
          }

          /// a normal character so must be the start of a word.
          stateStack.push(currentState);
          currentState = _ParseFrame(_ParseState.inWord, i);

          currentWord += char;

        /// if we are in escape mode.
        case _ParseState.escaped:
          currentState = stateStack.pop();

          /// if we were in searching mode then
          /// this character indicates the start of a word.
          if (currentState.state == _ParseState.searching) {
            stateStack.push(currentState);
            currentState = _ParseFrame(_ParseState.inWord, i);
          }
          currentWord += char;

        case _ParseState.inWord:

          /// A space indicates the end of a word.
          /// If it is inside a quote then we would be inQuote mode.
          // added ignore as lint has a bug for conditional in a
          // switch statement #27
          // ignore: invariant_booleans
          if (char == ' ') {
            // a non-escape/non-quoted space means a new part.
            currentState = stateStack.pop();
            if (currentState.state == _ParseState.searching) {
              parts.add(_QArg(currentWord));
              currentWord = '';
            } else {
              currentWord += char;
            }
            break;
          }

          /// The escape character so put us into
          /// escape mode so the escaped character will
          /// be treated as a normal char.
          // added ignore as lint has a bug for conditional in a
          // switch statement #27
          // ignore: invariant_booleans
          if (char == escapeCharacter) {
            stateStack.push(currentState);
            currentState = _ParseFrame(_ParseState.escaped, i);
            break;
          }

          /// quoted text in a word is treated as
          /// part of the same word but we still
          /// strip the quotes to match bash
          if (char == '"' || char == "'") {
            stateStack.push(currentState);
            currentState = _ParseFrame.forQuote(stateStack, i, char);
          } else {
            currentWord += char;
          }

        /// we are in a quote so just suck in
        /// characters until we see a matching quote.
        ///
        /// scenarios

        // "hi"
        // We are in a quote, parent is searching so strip quote
        //
        // hi="one"
        // We are in a quote, parent is word so keep the quote
        //
        // "abc 'one'"
        // If nested always keep the quote
        // If last quote if parent searching strip quote.
        //
        // hi="abc 'one'"
        // If parent is quote then keep quote
        // if parent is word then keep quote

        case _ParseState.inQuote:
          if (char == currentState.matchingQuote) {
            currentState = stateStack.pop();
            final state = currentState.state;

            // If we were searching or inWord then this will end the word
            if (state == _ParseState.searching || state == _ParseState.inWord) {
              /// If we are in a word then the quote also ends the word.
              if (state == _ParseState.inWord) {
                currentState = stateStack.pop();
              }

              parts.add(_QArg.fromParsed(currentWord, wasQuoted: true));
              currentWord = '';
            }
            break;
          }

          /// The escape character so put us into
          /// escape mode so the escaped character will
          /// be treated as a normal char.
          // added ignore as lint has a bug for conditional in a
          // switch statement #27
          // ignore: invariant_booleans
          if (char == escapeCharacter) {
            stateStack.push(currentState);
            currentState = _ParseFrame(_ParseState.escaped, i);
            break;
          }

          // we just hit a nested quote
          if (char == "'" || char == '"') {
            stateStack.push(currentState);
            currentState = _ParseFrame.forQuote(stateStack, i, char);
          }

          currentWord += char;

        /// we are in a quote so just suck in
        /// characters until we see a matching quote.
        case _ParseState.nestedQuote:

          if (char == currentState.matchingQuote) {
            // We have a matching closing quote
            currentState = stateStack.pop();
            currentWord += char;
            break;
          }

          /// The escape character so put us into
          /// escape mode so the escaped character will
          /// be treated as a normal char.
          // added ignore as lint has a bug for conditional in a
          // switch statement #27
          // ignore: invariant_booleans
          if (char == escapeCharacter) {
            stateStack.push(currentState);
            currentState = _ParseFrame(_ParseState.escaped, i);
            break;
          }

          if (char == "'" || char == '"') {
            // we just hit a nested quote
            stateStack.push(currentState);
            currentState = _ParseFrame.forQuote(stateStack, i, char);
          }
          currentWord += char;
      }
    }

    if (currentWord.isNotEmpty) {
      parts.add(_QArg.fromParsed(currentWord, wasQuoted: false));
    }

    if (parts.isEmpty) {
      throw InvalidArgumentException('The string did not contain a command.');
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
  /// See https://github.com/onepub-dev/dcli/issues/56
  ///
  List<String> _expandGlobs(List<_QArg> qargs, String? workingDirectory) {
    final expanded = <String>[];

    for (final qarg in qargs) {
      if (qarg.wasQuoted!) {
        expanded.add(qarg.arg);
      } else {
        expanded.addAll(qarg.expandGlob(workingDirectory));
      }
    }
    return expanded;
  }
}

enum _ParseState {
  /// we are between words (on a space or at the begining)
  searching,

  /// we have seen a quote and are looking for the next one.
  inQuote,

  /// The quote is nested within another quote.
  /// there can be multiple levels of nesting
  nestedQuote,

  /// we have seen a non-space character and are collecting
  /// all the pieces that make up the word.
  inWord,

  /// The next character is to be treated litterally
  escaped
}

class _ParseFrame {
  /// The state held by this Frame.
  _ParseState state;

  /// If the state for this [_ParseFrame] is [_ParseState.inQuote]
  /// then this holds the quote character that created the state.
  String? matchingQuote;

  /// The character offset from the start of the command line
  /// that caused us to enter this state.
  int offset;

  /// Create a [_ParseFrame]
  _ParseFrame(this.state, this.offset);

  /// Create a [_ParseFrame] when we enter the [_ParseState.inQuote] state.
  _ParseFrame.forQuote(
      StackList<_ParseFrame> stack, this.offset, this.matchingQuote)
      : state = isQuoteActive(stack)
            ? _ParseState.nestedQuote
            : _ParseState.inQuote;

  @override
  String toString() =>
      '${EnumHelper().getName(state)} offset: $offset quote: $matchingQuote';

  /// Returns true if a quote is already on the stack.
  static bool isQuoteActive(StackList<_ParseFrame> stack) {
    for (final frame in stack.asList()) {
      if (frame.state == _ParseState.inQuote ||
          frame.state == _ParseState.nestedQuote) {
        return true;
      }
    }
    return false;
  }
}

// TODO(bsutton): consider replacing with code from the dart sdk:
/// https://github.com/dart-lang/io/blob/master/lib/src/shell_words.dart
class _QArg {
  bool? wasQuoted;

  late String arg;

  _QArg(String iarg) {
    wasQuoted = false;
    arg = iarg.trim();

    if (arg.startsWith('"') && arg.endsWith('"')) {
      wasQuoted = true;
    }
    if (arg.startsWith("'") && arg.endsWith("'")) {
      wasQuoted = true;
    }

    if (wasQuoted!) {
      arg = arg.substring(1, arg.length - 1);
    }
  }

  _QArg.fromParsed(this.arg, {required this.wasQuoted});

  /// We only do glob expansion if the arg contains at least one of
  /// *, [, ?
  ///
  /// Note: under Windows powershell does perform glob expansion so we need
  /// to supress glob expansion.
  bool get needsExpansion =>
      !Settings().isWindows &&
      (arg.contains('*') || arg.contains('[') || arg.contains('?'));

  static List<_QArg> translate(List<String?> args) {
    final qargs = <_QArg>[];
    for (final arg in args) {
      final qarg = _QArg(arg!);
      qargs.add(qarg);
    }
    return qargs;
  }

  Iterable<String> expandGlob(String? workingDirectory) {
    final expanded = <String>[];
    if (arg.contains('~')) {
      arg = arg.replaceAll('~', HOME);
    }
    if (needsExpansion) {
      final files = _expandGlob(workingDirectory!);

      /// translate the files to relative paths if appropriate.
      for (var file in files) {
        if (isWithin(workingDirectory, file!)) {
          file = relative(file, from: workingDirectory);
        }
        expanded.add(file);
      }
    } else {
      expanded.add(arg);
    }
    return expanded;
  }

  Iterable<String?> _expandGlob(String workingDirectory) {
    final glob = Glob(arg);

    /// we are interested in the last part of the arg.
    /// e.g. of  path/.* we want the .*
    final includeHidden = basename(arg).startsWith('.');

    var files = <FileSystemEntity>[];

    files = glob.listFileSystemSync(
      const LocalFileSystem(),
      root: workingDirectory,
    );

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
  bool isHidden(String workingDirectory, FileSystemEntity entity) {
    final relativePath =
        truepath(relative(entity.path, from: workingDirectory));

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
