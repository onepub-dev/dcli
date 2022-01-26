import 'package:dcli/src/script/entry_point.dart';
import 'package:test/test.dart';

void main() {
  test('entry point ...', () async {
    EntryPoint().process(['--verbose', 'create']);
  });
}
