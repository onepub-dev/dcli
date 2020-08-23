@Timeout(Duration(minutes: 5))
import 'package:dcli/src/script/pub_get.dart';
import 'package:dcli/src/script/script.dart';
import 'package:dcli/src/script/virtual_project.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

String scriptPath = 'test/test_scripts/general/bin/hello_world.dart';

void main() {
  group('Pub Get', () {
    test('Do it', () {
      TestFileSystem().withinZone((fs) {
        var script = Script.fromFile('test/test_scripts/general/bin/hello_world.dart');
        var project = VirtualProject.create(script);
        PubGet(project).run();
      });
    });
  });
}
