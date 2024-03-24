import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('capture ...', () async {
    final myprogress = Progress.capture();
    final progress = await capture(() async {
      print('hi');
      printerr('ho');
    }, progress: myprogress);

    expect(progress.lines.length, equals(2));
    expect(progress.lines.first, equals('hi'));
    expect(progress.lines[1], equals('ho'));
  });

  test('dcli zone ...', () async {
    final progress = await capture(() async {
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
    expect(lines.length, equals(9));
    expect(lines.first, equals('Hello1'));
    expect(lines.last, equals('Hello4'));
  });
}
