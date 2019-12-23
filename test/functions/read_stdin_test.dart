import 'package:dshell/src/util/runnable_process.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  // can't be run from within vscode as it needs console input.
  t.group('Read from stdin', () {
    t.test('Read and then write ', () {
      TestZone().run(() {
        readStdin().forEach(console);
      });
    }, skip: true);
  });
}
