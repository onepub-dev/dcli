import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/commands/incremental_compiler.dart';
import 'package:test/test.dart';

void main() {
  test('incremental compile ...', () async {
    final compiler =
        IncrementalCompiler(join('test', 'test_script', 'back.dart'));

    await compiler.watch();
  });
}
