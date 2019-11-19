import 'dart:io';

import 'package:dshell/commands/command.dart';
import 'package:dshell/util/for_each.dart';
import 'package:file_utils/file_utils.dart' as util;

import '../dshell.dart';
import 'settings.dart';

import '../util/log.dart';

///
/// Returns the list of files in the current
/// directory that match the passed glob pattern.
///
/// Valid patterns are:
///
/// Note> the surround square brackets are not part of the pattern.
///
/// [*] - matches any number of any characters including none
///
/// [?] -  matches any single character
///
/// [[abc]] - matches any one character given in the bracket
///
/// [[a-z]] - matches one character from the range given in the bracket
///
/// [[!abc]] - matches one character that is not given in the bracket
///
/// [[!a-z]] - matches one character that is not from the range given in the bracket
///
/// If [caseSensitive] is true then a case sensitive match is performed.
/// [caseSensitive] defaults to false.
///
/// If [recursive] is true then a recursive search of all subdirectories
///    (all the way down) is performed.
/// [recursive] is true by default.
///
/// [types] allows you to specify the file types you want the find to return.
/// By default [types] limits the results to files.
///

class PatternMatcher {
  String pattern;
  RegExp regEx;
  bool caseSensitive;

  PatternMatcher(this.pattern, this.caseSensitive) {
    regEx = buildRegEx();
  }

  bool match(String value) {
    return regEx.stringMatch(value) == value;
  }

  RegExp buildRegEx() {
    String regEx = "";

    for (int i = 0; i < pattern.length; i++) {
      String char = pattern[i];

      switch (char) {
        case '[':
          regEx += "[";
          break;
        case ']':
          regEx += "]";
          break;
        case '*':
          regEx += '.*';
          break;
        case '?':
          regEx += ".";
          break;
        case '-':
          regEx += "-";
          break;
        case '!':
          regEx += "^";
          break;
        case ".":
          regEx += "\\.";
          break;
        default:
          regEx += char;
          break;
      }
    }
    return RegExp(regEx, caseSensitive: caseSensitive);
  }
}

ForEach find(String pattern,
        {bool caseSensitive = false,
        bool recursive = true,
        String root = ".",
        List<FileSystemEntityType> types = const [
          FileSystemEntityType.file
        ]}) =>
    Find().find(pattern,
        caseSensitive: caseSensitive,
        recursive: recursive,
        root: root,
        types: types);

class Find extends Command {
  ForEach find(String pattern,
      {bool caseSensitive = false,
      bool recursive = true,
      String root = ".",
      List<FileSystemEntityType> types = const [FileSystemEntityType.file]}) {
    PatternMatcher matcher = PatternMatcher(pattern, caseSensitive);

    ForEach forEach = ForEach();

    if (Settings().debug_on) {
      Log.d(
          "find: pwd: ${pwd} ${absolute(root)} pattern: ${pattern} caseSensitive: ${caseSensitive} recursive: ${recursive} types: ${types} ");
    }

    // get all files for consideration
    // this could be problematic for a large tree.
    // would be better if we process the files as we went.
    List<FileSystemEntity> all = Directory(root).listSync(recursive: recursive);

    // TODO: consider doing a directory at a time so we don't blow all memory.
    for (var entity in all) {
      FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
      if (types.contains(type) && matcher.match(entity.path)) {
        forEach.addToStdout(entity.path);
      }
    }

    forEach.close();

    return forEach;
  }
}
