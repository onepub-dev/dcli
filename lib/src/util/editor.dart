import 'dart:io';

import '../../dshell.dart';

/// Launches the systems default cli editor on Linux and MacOS
/// using the EDITOR environment variable.
///
/// On Windows we launch notepad.
///
/// If the EDITOR environment variable isn't found then
/// we check for the VISUAL environment variable.
/// If neither is found we use vi.
///
///
/// EXPERIMENTAL
void showEditor(String path) {
  String editor;
  if (Platform.isWindows) {
    editor = 'notepad.exe';
  } else {
    editor = env('EDITOR');
    editor ??= env('VISIBLE');
    editor ??= 'vi';
  }

  // https://github.com/git/git/blob/master/editor.c
  '$editor $path'.start(terminal: true);
}

bool isTerminalDumb() {
  {
    var terminal = env('TERM');
    return terminal == null || terminal == 'dumb';
  }
}
