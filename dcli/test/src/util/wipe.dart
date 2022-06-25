/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */


import 'package:dcli/dcli.dart';

/// Wipes the entire HOME/.dcli directory tree.
void wipe() {
  final dcliPath = Settings().pathToDCli;
  if (exists(dcliPath)) {
    deleteDir(dcliPath);
  }
}
