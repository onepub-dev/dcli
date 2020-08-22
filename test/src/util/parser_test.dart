@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  test('Parser', () {
    TestFileSystem().withinZone((fs) {
      var jsonFile = join(fs.root, 'sample.json');
      jsonFile.write('''{ 
  "a": 456,
  "d": "yes"
}''');

      expect('cat $jsonFile'.parser().jsonDecode()['a'], 456);

      var csvFile = join(fs.root, 'sample.csv');
      csvFile.write('''"a", 456,"d", "yes"''');
      expect('cat $csvFile'.parser().csvDecode()[0][0], 'a');

      var yamlFile = join(fs.root, 'sample.yaml');
      yamlFile.write('''name: pubspec_local
version: 1.0.0
environment: 
  sdk: '>=2.6.0 <3.0.0'
dependencies: 
  dcli: ^0.20.0''');
      expect('cat $yamlFile'.parser().yamlDecode()['name'], 'pubspec_local');

      var iniFile = join(fs.root, 'sample.init');
      iniFile.write('''[name]
debug=true''');
      expect('cat $iniFile'.parser().iniDecode().hasSection('name'), true);
    });
  }, skip: false);
}
