@Timeout(Duration(minutes: 5))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */



import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/my_yaml.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Project Name', () {
    TestFileSystem().withinZone((fs) {
      print(pwd);
      final yaml = MyYaml.fromFile('pubspec.yaml');
      final projectName = yaml.getValue('name');

      expect(projectName, equals('dcli'));
    });
  });
}
