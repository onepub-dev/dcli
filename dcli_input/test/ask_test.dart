// ignore_for_file: unused_result

@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:checks/checks.dart';
import 'package:dcli_input/src/ask.dart';
import 'package:dcli_terminal/dcli_terminal.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('ask.custom prompt', () async {
    // expect("AAAHow old ar you:5", () {
    await ask(
      'How old are you',
      defaultValue: '5',
      customPrompt: (prompt, defaultValue, hidden) =>
          'AAA$prompt:$defaultValue',
    );
    // }).send("6");
  }, skip: true);

  test(
    'defaultValue',
    () async {
      var result = await ask('How old are you', defaultValue: '5');
      print('result: $result');
      result = await ask('How old are you',
          defaultValue: '5', validator: Ask.integer);
      print('result: $result');
    },
    skip: true,
  );

  test(
    'range',
    () async {
      final result = await ask(
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
    () async {
      final validator = Ask.regExp(r'^[a-zA-Z0-9_\-]+');

      await check(validator.validate('!')).throws<AskValidatorException>(
        it()
          ..has(
              (e) => e.message, red(r'Input does not match: ^[a-zA-Z0-9_\-]+')),
      );

      check(await validator.validate('_')).equals('_');
    },
    skip: false,
  );

  test('ask.any - success', () async {
    final validator = Ask.any([
      Ask.fqdn,
      Ask.ipAddress(),
      Ask.inList(['localhost'])
    ]);

    check('localhost').equals(await validator.validate('localhost'));
  });

  test('ask.any - throws', () async {
    final validator = Ask.any([
      Ask.fqdn,
      Ask.ipAddress(),
      Ask.inList(['localhost'])
    ]);

    await check(validator.validate('abc')).throws<AskValidatorException>(
        it()..has((e) => e.message, red('Invalid FQDN.')));
  });

  test('ask.all - success', () async {
    final validator = Ask.all([
      Ask.integer,
      Ask.valueRange(10, 25),
      Ask.inList(['11', '12', '13'])
    ]);

    check(await validator.validate('11')).equals('11');
  });

  test('ask.all - failure', () async {
    final validator = Ask.all([
      Ask.integer,
      Ask.valueRange(10, 25),
      Ask.inList(['11', '12', '13'])
    ]);

    await check(validator.validate('9')).throws<AskValidatorException>(it()
      ..has((e) => e.message,
          red('The number must be greater than or equal to 10.')));
  });

  test('ask.integer - failure', () async {
    const validator = Ask.integer;

    await check(validator.validate('a')).throws<AskValidatorException>(
        it()..has((e) => e.message, red('Invalid integer.')));

    check(await validator.validate('9')).equals('9');
  });

  test('ask.url - default protocols', () async {
    final validator = Ask.url();

    check(await validator.validate('https://onepub.dev')).equals(
      'https://onepub.dev',
    );

    await check(validator.validate('http://onepub.dev'))
        .throws<AskValidatorException>(
            it()..has((e) => e.message, red('Invalid URL.')));
  });

  test('ask.url - custom protocols', () async {
    final validator = Ask.url(protocols: ['https', 'http', 'abc']);

    check(await validator.validate('https://onepub.dev'))
        .equals('https://onepub.dev');
    check(await validator.validate('http://onepub.dev'))
        .equals('http://onepub.dev');
    check(await validator.validate('abc://onepub.dev'))
        .equals('abc://onepub.dev');

    await check(validator.validate('def://onepub.dev'))
        .throws<AskValidatorException>(
            it()..has((e) => e.message, red('Invalid URL.')));
  });
}
