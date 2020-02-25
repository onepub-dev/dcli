#! /usr/bin/env dshell
@Timeout(Duration(seconds: 600))

import 'package:dshell/src/util/parse_cli_command.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('glob expansion', () {
    TestFileSystem().withinZone((fs) {
      var parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          equals([
            join(fs.top, 'fred.jpg'),
            join(fs.top, 'one.jpg'),
            join(fs.top, 'fred.png'),
          ]));
    });
  });
}
