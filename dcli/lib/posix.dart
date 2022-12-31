/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
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
