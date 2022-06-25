#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */




import 'package:dcli/dcli.dart';

/// Runs the install tests by cloning the dcli git repo.
///
void main() {
  /// --no-cache is used as we want the git clone to occur every time
  /// so we are always running of the latest version
  'sudo docker build --no-cache -f ./install.clone.df -t dcli:install_test ..'
      .run;
}
