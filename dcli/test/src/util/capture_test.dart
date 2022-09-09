import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('capture ...', () async {
    final myprogress = Progress.capture();
    final progress = capture(() async {
      print('hi');
      printerr('ho');
    }, progress: myprogress);


    expect(progress.lines.length, equals(2));
    expect(progress.lines.first, equals('hi'));
    expect(progress.lines[1], equals('ho'));
  });
}
