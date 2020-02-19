#! /usr/bin/env dshell
import 'package:dshell/src/util/parse_cli_command.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('glob expansion', () {
    TestFileSystem().withinZone((fs) {
      var parsed = ParsedCliCommand('ls *.jpg *.txt');

      expect(parsed.cmd, equals('ls'));

      expect(parsed.args, equals(['a']));
    });
  });
}
