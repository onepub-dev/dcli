import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/script/my_yaml.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  test('Project Name', () {
    TestFileSystem().withinZone((fs) {
      print('$pwd');
      var yaml = MyYaml.fromFile('pubspec.yaml');
      var projectName = yaml.getValue('name');

      expect(projectName, equals('dshell'));
    });
  });
}
