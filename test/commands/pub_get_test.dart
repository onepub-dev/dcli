
import 'package:dshell/script/dart_sdk.dart';
import 'package:dshell/script/pub_get.dart';
import 'package:dshell/script/script.dart';
import 'package:dshell/script/virtual_project.dart';
import 'package:dshell/settings.dart';
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';

String scriptPath = "test/test_scripts/hello_world.dart";

void main() {
  group("Pub Get", () {
    test('Do it', () {
      TestZone().run(() {
        Script script = Script.fromFile("test/test_scripts/hello_world.dart");
        VirtualProject project = VirtualProject(Settings().cachePath, script);
        DartSdk sdk = DartSdk();
        PubGet(sdk, project).run();
      });
    });
  });
}
