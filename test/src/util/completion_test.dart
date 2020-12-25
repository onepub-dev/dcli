@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/completion.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  group('completion ...', () {
    TestFileSystem(installDcli: false).withinZone((fs) {
      final root = join(fs.fsRoot, 'top');

      List<String> paths;
      test('empty word', () async {
        final paths = completionExpandScripts('', workingDirectory: root);
        expect(
            paths,
            unorderedEquals(<String>[
              'fred.jpg',
              'fred.png',
              'one.txt',
              'two.txt',
              'one.jpg',
              'middle/'
            ]));
      });

      test('single match', () async {
        paths = completionExpandScripts('middl', workingDirectory: root);
        expect(
            paths,
            unorderedEquals(<String>[
              'middle/',
            ]));
      });

      test('directory with trailing slash', () async {
        paths = completionExpandScripts('middle/', workingDirectory: root);
        expect(
            paths,
            unorderedEquals(<String>[
              'middle/bottom/',
              'middle/four.txt',
              'middle/three.txt',
              'middle/two.jpg',
            ]));
      });

      /// need a test where we enter a partial directory and two directories match
      /// the completion seems to auto complete to the first exact match.
      /// e.g.
      /// doc
      /// docker
      /// match word: doc which then return doc/
      test('two matching directories', () {
        final mid = join(root, 'mid');
        if (!exists(mid)) createDir(mid);
        paths = completionExpandScripts('mid', workingDirectory: root);
        deleteDir(mid);
        expect(
            paths,
            unorderedEquals(<String>[
              'mid/',
              'middle/',
            ]));
      });

      test('directory as word', () async {
        paths = completionExpandScripts('middle', workingDirectory: root);
        expect(
            paths,
            unorderedEquals(<String>[
              'middle/',
            ]));
      });

      test('invalid directory', () async {
        paths = completionExpandScripts('muddle/', workingDirectory: root);
        expect(paths, <String>[]);
      });

      test('directory and letter', () async {
        paths = completionExpandScripts('middle/t', workingDirectory: root);
        expect(paths,
            unorderedEquals(<String>['middle/two.jpg', 'middle/three.txt']));
      });
    });
  });
}
