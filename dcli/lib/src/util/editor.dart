/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import '../../dcli.dart';

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
  String? editor;
  if (Settings().isWindows) {
    editor = 'notepad.exe';
  } else {
    editor = env['EDITOR'];
    editor ??= env['VISIBLE'];
    editor ??= 'vi';
  }

  // https://github.com/git/git/blob/master/editor.c
  '$editor $path'.start(terminal: true);
}

/// True if the console is a dumb termainl
bool isTerminalDumb() {
  {
    final terminal = env['TERM'];
    return terminal == null || terminal == 'dumb';
  }
}
