@Timeout(Duration(seconds: 600))
import 'package:dshell/src/script/dart_sdk.dart';
import 'package:dshell/src/script/pub_get.dart';
import 'package:dshell/src/script/script.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:dshell/src/settings.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

String scriptPath = 'test/test_scripts/hello_world.dart';

void main() {

  group('Pub Get', () {
    test('Do it', () {
      TestFileSystem().withinZone((fs) {
        var script = Script.fromFile('test/test_scripts/hello_world.dart');
        var project = VirtualProject.load(Settings().dshellCachePath, script);
        var sdk = DartSdk();
        PubGet(sdk, project).run();
      });
    });
  });
}
