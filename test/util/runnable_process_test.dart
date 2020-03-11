@Timeout(Duration(minutes: 10))

import 'dart:io';



import 'package:dshell/src/functions/run.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('runnable process Start - forEach', () {
    TestFileSystem().withinZone((fs) async {
      var path = join(fs.root, 'top');
      print('starting ls in ${path}');

      String command;
      var skipLines = 0;
      if (Platform.isWindows)
      {

        command = 'get-item  *.txt'; //  | Format-Wide -Property Name -Column 1';
        skipLines = 1;

      }
      else
      {
        command = 'ls *.txt';

      }
      var found = <String>[];
      start(command, workingDirectory: path)
          .forEach((file) {
            if (skipLines == 0)
            {
            found.add(file);
            }
            else
            {
              skipLines--;
            }
          });

      expect(found, <String>[
        join(path, 'one.txt'),
        //join(path, '.two.txt'), // we should not be expanding .xx.txt
        join(path, 'two.txt')
      ]);
    });
  });
}
