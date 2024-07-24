@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/src/test_directory_tree.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Parser',
    () async {
      await withTempDirAsync((fsRoot) async {
        TestDirectoryTree(fsRoot);

        final jsonFile = join(fsRoot, 'sample.json')
          ..write(
            '''
{ 
  "a": 456,
  "d": "yes"
}''',
          );

        final parser = 'cat $jsonFile'.parser();
        expect((parser.jsonDecode() as Map)['a'], 456);

        final csvFile = join(fsRoot, 'sample.csv')
          ..write('''"a", 456,"d", "yes"''');
        expect('cat $csvFile'.parser().csvDecode()[0][0], 'a');

        final yamlFile = join(fsRoot, 'sample.yaml')
          ..write(
            '''
name: pubspec_local
version: 1.0.0
environment: 
  sdk: '>=2.6.0 <3.0.0'
dependencies: 
  dcli: ^0.20.0''',
          );

        final yamlParser = 'cat $yamlFile'.parser();
        expect((yamlParser.yamlDecode() as Map)['name'], 'pubspec_local');

        join(fsRoot, 'sample.init').write(
          '''
[name]
debug=true''',
        );
        // expect('cat $iniFile'.parser().iniDecode().hasSection('name'), true);
      });
    },
    skip: false,
  );
}
