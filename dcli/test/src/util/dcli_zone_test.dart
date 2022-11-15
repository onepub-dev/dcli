import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('dcli zone ...', () async {
    final progress = await DCliZone().run(() async {
      print('Hello1');
      printerr('World1');
      print('Hello2');
      printerr('World2');
      print('Hello3');
      printerr('World3');
      print('Hello4');
      printerr('World4');
      print('Hello4');
    }, progress: Progress.capture());

    final lines = progress.lines;
    expect(lines.length, equals(8));
    expect(lines.first, equals('Hello1'));
  });
}
