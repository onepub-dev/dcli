/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

/// barrel file for posix specific functions.
library posix;

export 'src/posix/chmod.dart' show ChModException, chmod;
export 'src/posix/chown.dart' show ChOwnException, chown;
export 'src/shell/ash_shell.dart';
export 'src/shell/bash_shell.dart';
export 'src/shell/dash_shell.dart';
export 'src/shell/fish_shell.dart';
export 'src/shell/posix_shell.dart';
export 'src/shell/sh_shell.dart';
export 'src/shell/zsh_shell.dart';
