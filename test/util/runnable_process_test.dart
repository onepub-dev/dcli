#! /usr/bin/env dshell
@Timeout(Duration(minutes: 10))

import 'package:dshell/src/functions/run.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('runnable process Start - forEach', () {
    TestFileSystem().withinZone((fs) async {
      var path = join(fs.root, 'top');
      print('starting ls in ${path}');
      var found = <String>[];
      start('ls *.txt', workingDirectory: path)
          .forEach((file) => found.add(file));

      expect(found, <String>[]);
    });
  });
}
