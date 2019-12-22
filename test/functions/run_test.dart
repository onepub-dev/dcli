import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;
  t.group('RunCommand', () {
    t.test('Run', () {
      TestZone().run(() {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });
  });
}
