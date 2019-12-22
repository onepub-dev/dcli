import 'package:dshell/dshell.dart';
import 'package:dshell/script/my_yaml.dart';
import 'package:test/test.dart' as t;

import 'util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.test('Project Name', () {
    TestZone().run(() {
      print('$pwd');
      var yaml = MyYaml.loadFromFile('pubspec.yaml');
      var projectName = yaml.getValue('name');

      t.expect(projectName, t.equals('dshell'));
    });
  });
}
