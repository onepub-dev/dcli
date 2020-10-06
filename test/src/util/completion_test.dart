@Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/completion.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  group('completion ...', () {
    TestFileSystem().withinZone((fs) {
      var root = join(fs.fsRoot, 'top');

      List<String> paths;
      test('empty word', () async {
        var paths = completionExpandScripts('', workingDirectory: root);
        expect(paths, unorderedEquals(<String>['fred.jpg', 'fred.png', 'one.txt', 'two.txt', 'one.jpg', 'middle']));
      });

      test('directory as word', () async {
        paths = completionExpandScripts('middle', workingDirectory: root);
        expect(
            paths,
            unorderedEquals(<String>[
              'middle/bottom',
              'middle/four.txt',
              'middle/three.txt',
              'middle/two.jpg',
            ]));
      });

      test('directory and letter', () async {
        paths = completionExpandScripts('middle/t', workingDirectory: root);
        expect(paths, unorderedEquals(<String>['middle/two.jpg', 'middle/three.txt']));
      });
    });
  });
}
