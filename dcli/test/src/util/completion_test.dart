@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */




/// command line completion for dcli
/// is only supported on lunix.
@TestOn('!windows')

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/completion.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  group('completion ...', () {
    List<String> paths;
    test('empty word', () async {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

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
          ]),
        );
      });
    });

    test('single match', () async {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

        paths = completionExpandScripts('middl', workingDirectory: root);
        expect(
          paths,
          unorderedEquals(<String>[
            'middle/',
          ]),
        );
      });
    });

    test('directory with trailing slash', () async {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

        paths = completionExpandScripts('middle/', workingDirectory: root);
        expect(
          paths,
          unorderedEquals(<String>[
            'middle/bottom/',
            'middle/four.txt',
            'middle/three.txt',
            'middle/two.jpg',
          ]),
        );
      });
    });

    /// need a test where we enter a partial directory
    ///  and two directories match
    /// the completion seems to auto complete to the first exact match.
    /// e.g.
    /// doc
    /// docker
    /// match word: doc which then return doc/
    test('two matching directories', () {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

        final mid = join(root, 'mid');
        if (!exists(mid)) {
          createDir(mid);
        }
        paths = completionExpandScripts('mid', workingDirectory: root);
        deleteDir(mid);
        expect(
          paths,
          unorderedEquals(<String>[
            'mid/',
            'middle/',
          ]),
        );
      });
    });

    test('directory as word', () async {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

        paths = completionExpandScripts('middle', workingDirectory: root);
        expect(
          paths,
          unorderedEquals(<String>[
            'middle/',
          ]),
        );
      });
    });

    test('invalid directory', () async {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

        paths = completionExpandScripts('muddle/', workingDirectory: root);
        expect(paths, <String>[]);
      });
    });

    test('directory and letter', () async {
      withTempDir((fsRoot) {
        TestDirectoryTree(fsRoot);
        final root = join(fsRoot, 'top');

        paths = completionExpandScripts('middle/t', workingDirectory: root);
        expect(
          paths,
          unorderedEquals(<String>['middle/two.jpg', 'middle/three.txt']),
        );
      });
    });
  });
}
