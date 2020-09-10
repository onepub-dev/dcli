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
        defaultValue: '5', validator: Ask.lengthRange(4, 7));
    print('result: $result');
  }, skip: true);

  test('confirm no default', () {
    var result = confirm('Are you good?');
    print('result: $result');
  }, skip: true);

  test('confirm default=true', () {
    var result = confirm('Are you good?', defaultValue: true);
    print('result: $result');
  }, skip: true);

  test('confirm default=false', () {
    var result = confirm('Are you good?', defaultValue: false);
    print('result: $result');
  }, skip: true);

  test('ask.any - success', () {
    var validator = Ask.any([
      Ask.fqdn,
      Ask.ipAddress(),
      Ask.inList(['localhost'])
    ]);

    expect('localhost', validator.validate('localhost'));
  });

  test('ask.any - throws', () {
    var validator = Ask.any([
      Ask.fqdn,
      Ask.ipAddress(),
      Ask.inList(['localhost'])
    ]);

    expect(
        () => validator.validate('abc'),
        throwsA(predicate<AskValidatorException>((e) =>
            e is AskValidatorException && e.message == 'Invalid FQDN.')));
  });

  test('ask.all - success', () {
    var validator = Ask.all([
      Ask.integer,
      Ask.valueRange(10, 25),
      Ask.inList(['11', '12', '13'])
    ]);

    expect('11', validator.validate('11'));
  });

  test('ask.all - failure', () {
    var validator = Ask.all([
      Ask.integer,
      Ask.valueRange(10, 25),
      Ask.inList(['11', '12', '13'])
    ]);

    expect(
        () => validator.validate('9'),
        throwsA(predicate<AskValidatorException>((e) =>
            e is AskValidatorException &&
            e.message ==
                red('The number must be greater than or equal to 10.'))));
  });
}
