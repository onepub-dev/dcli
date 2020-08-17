#! /usr/bin/env dshell

import 'package:dshell/dshell.dart';

/// Runs the install tests by cloning the dshell git repo.
///
void main() {
  /// --no-cache is used as we want the git clone to occur every time
  /// so we are always running of the latest version
  'sudo docker build --no-cache -f ./all.clone.df -t dshell:all_clone_test ..'
      .run;
}
