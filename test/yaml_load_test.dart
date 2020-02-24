@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:dshell/src/script/my_yaml.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

import 'util/test_file_system.dart';

void main() {
  Settings().debug_on = true;

  t.test('Project Name', () {
    TestFileSystem().withinZone((fs) {
      print('$pwd');
      var yaml = MyYaml.fromFile('pubspec.yaml');
      var projectName = yaml.getValue('name');

      t.expect(projectName, t.equals('dshell'));
    });
  });
}
