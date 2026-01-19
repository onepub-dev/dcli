@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/my_yaml.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(InvalidType)
void main() {
  test('Project Name', () async {
    await TestFileSystem().withinZone((fs) async {
      print(pwd);
      final yaml = MyYaml.fromFile('pubspec.yaml');
      final projectName = yaml.getValue('name');

      expect(projectName, equals('dcli'));
    });
  });
}
