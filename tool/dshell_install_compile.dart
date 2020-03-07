#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

import 'package:dshell/src/util/pub_cache.dart';

///
/// compiles a copy of dshell_install and copies it to ~/pub-cache/bin
// Used during testing of install_dshell.dart so we are certain
// it has the latest version.
void main() {
  try {
    DartSdk().runDart2Native(
        '../bin/dshell_install.dart', PubCache().binPath, '.');
  } finally {}
}
