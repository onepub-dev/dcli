@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart' hide equals;
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
    final result = ask('Range Test: How old are you',
        defaultValue: '5', validator: Ask.lengthRange(4, 7));
    print('result: $result');
  }, skip: true);

  test('regexp', () {
    final validator = Ask.regExp(r'^[a-zA-Z0-9_\-]+');

    expect(
        () => validator.validate('!'),
        throwsA(predicate<AskValidatorException>((e) =>
            e is AskValidatorException &&
            e.message == red(r'Input does not match: ^[a-zA-Z0-9_\-]+'))));

    expect(validator.validate('_'), '_');
  }, skip: false);

  test('confirm no default', () {
    final result = confirm('Are you good?');
    print('result: $result');
  }, skip: true);

  test('confirm default=true', () {
    final result = confirm('Are you good?', defaultValue: true);
    print('result: $result');
  }, skip: true);

  test('confirm default=false', () {
    final result = confirm('Are you good?', defaultValue: false);
    print('result: $result');
  }, skip: true);

  test('ask.any - success', () {
    final validator = Ask.any([
      Ask.fqdn,
      Ask.ipAddress(),
      Ask.inList(['localhost'])
    ]);

    expect('localhost', validator.validate('localhost'));
  });

  test('ask.any - throws', () {
    final validator = Ask.any([
      Ask.fqdn,
      Ask.ipAddress(),
      Ask.inList(['localhost'])
    ]);

    expect(
        () => validator.validate('abc'),
        throwsA(predicate<AskValidatorException>((e) =>
            e is AskValidatorException && e.message == red('Invalid FQDN.'))));
  });

  test('ask.all - success', () {
    final validator = Ask.all([
      Ask.integer,
      Ask.valueRange(10, 25),
      Ask.inList(['11', '12', '13'])
    ]);

    expect('11', validator.validate('11'));
  });

  test('ask.all - failure', () {
    final validator = Ask.all([
      Ask.integer,
      Ask.valueRange(10, 25),
      Ask.inList(['11', '12', '13'])
    ]);

    expect(
        () => validator.validate('9'),
        throwsA(isA<AskValidatorException>().having((e) => e.message, 'message',
            equals(red('The number must be greater than or equal to 10.')))));
  });

  test('ask.integer - failure', () {
    const validator = Ask.integer;

    expect(
        () => validator.validate('a'),
        throwsA(predicate<AskValidatorException>((e) =>
            e is AskValidatorException &&
            e.message == red('Invalid integer.'))));

    expect(validator.validate('9'), equals('9'));
  });
}
