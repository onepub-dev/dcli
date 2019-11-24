@Timeout(Duration(seconds: 600))

import 'package:dshell/script/entry_point.dart';
import 'package:test/test.dart';

void main() {
  test('Run hello world', () {
    int exitCode =
        EntryPoint().process(["test/test_scripts/hello_world.dart", "world"]);

    expect(exitCode, equals(0));
  });
}
