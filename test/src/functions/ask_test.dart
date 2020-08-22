@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('defaultValue', () {
    Settings().setVerbose(enabled: false);
    var result = ask('How old are you', defaultValue: '5');
    print('result: $result');
    result = ask('How old are you', defaultValue: '5', validator: Ask.integer);
    print('result: $result');
  }, skip: true);

  test('range', () {
    var result = ask('Range Test: How old are you',
        defaultValue: '5', validator: AskRange(4, 7));
    print('result: $result');
  }, skip: true);
}
