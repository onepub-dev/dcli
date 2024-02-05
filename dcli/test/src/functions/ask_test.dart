@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/src/functions/ask.dart';
import 'package:dcli/src/settings.dart';
import 'package:dcli/src/util/ansi_color.dart';
import 'package:test/test.dart';

void main() {
  test('ask.custom prompt', () {
    Settings().setVerbose(enabled: false);

    // expect("AAAHow old ar you:5", () {
    ask(
      'How old are you',
      defaultValue: '5',
      customPrompt: (prompt, defaultValue, hidden) =>
          'AAA$prompt:$defaultValue',
    );
    // }).send("6");
  }, skip: true);

  test(
    'defaultValue',
    () {
      Settings().setVerbose(enabled: false);
      var result = ask('How old are you', defaultValue: '5');
      print('result: $result');
      result =
          ask('How old are you', defaultValue: '5', validator: Ask.integer);
      print('result: $result');
    },
    skip: true,
  );

  test(
    'range',
    () {
      final result = ask(
        'Range Test: How old are you',
        defaultValue: '5',
        validator: Ask.lengthRange(4, 7),
      );
      print('result: $result');
    },
    skip: true,
  );

  test(
    'regexp',
    () {
      final validator = Ask.regExp(r'^[a-zA-Z0-9_\-]+');

      expect(
        () => validator.validate('!'),
        throwsA(
          predicate<AskValidatorException>(
            (e) => e.message == red(r'Input does not match: ^[a-zA-Z0-9_\-]+'),
          ),
        ),
      );

      expect(validator.validate('_'), '_');
    },
    skip: false,
  );

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
      throwsA(
        predicate<AskValidatorException>(
          (e) => e.message == red('Invalid FQDN.'),
        ),
      ),
    );
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
      throwsA(
        isA<AskValidatorException>().having(
          (e) => e.message,
          'message',
          equals(red('The number must be greater than or equal to 10.')),
        ),
      ),
    );
  });

  test('ask.integer - failure', () {
    const validator = Ask.integer;

    expect(
      () => validator.validate('a'),
      throwsA(
        predicate<AskValidatorException>(
          (e) => e.message == red('Invalid integer.'),
        ),
      ),
    );

    expect(validator.validate('9'), equals('9'));
  });

  test('ask.url - default protocols', () {
    final validator = Ask.url();

    expect('https://onepub.dev', validator.validate('https://onepub.dev'));

    expect(
      () => validator.validate('http://onepub.dev'),
      throwsA(
        isA<AskValidatorException>().having(
          (e) => e.message,
          'message',
          equals(red('Invalid URL.')),
        ),
      ),
    );
  });

  test('ask.url - custom protocols', () {
    final validator = Ask.url(protocols: ['https', 'http', 'abc']);

    expect('https://onepub.dev', validator.validate('https://onepub.dev'));
    expect('http://onepub.dev', validator.validate('http://onepub.dev'));
    expect('abc://onepub.dev', validator.validate('abc://onepub.dev'));

    expect(
      () => validator.validate('def://onepub.dev'),
      throwsA(
        isA<AskValidatorException>().having(
          (e) => e.message,
          'message',
          equals(red('Invalid URL.')),
        ),
      ),
    );
  });
}
