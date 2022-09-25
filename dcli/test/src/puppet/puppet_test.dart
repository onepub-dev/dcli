import 'dart:async';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/puppet/puppet.dart';
import 'package:test/test.dart';

void main() {
  test('spawn', () async {
    var spawned = false;
    final puppet = Puppet(spawn: () async {
      spawned = true;
    })
      ..run();

    expect(spawned, isTrue);
  });

  test('send', () async {
    String? received;
    stdin;
    Puppet<void>(spawn: () async {
      received = stdin.readLineSync();
    })
      ..send('ABC')
      ..run();
    expect(received, 'ABC');
  });

  test('expect', () async {
    var received = false;
    Puppet<void>(spawn: () async {
      print('ABCD');
    })
      ..expect('ABCD', action: () => received = true)
      ..run();
    expect(received, isTrue);
  });

  test('puppet', () {
    Puppet<String>(spawn: () async {
      final age = ask(
        'How old are you',
        defaultValue: '5',
        customPrompt: (prompt, defaultValue, hidden) =>
            'AAA$prompt:$defaultValue',
      );
      print('You are $age years old');
      return age;
    })
      ..expect('AAAHow old ar you:5')
      ..send('6')
      ..expect('You are 6 years old')
      ..run();
  });

  test('puppet - ask', () async {
    Settings().setVerbose(enabled: true);
    final completer = Completer<bool>();
    Puppet<String>(spawn: () async {
      final age = ask(
        'How old are you',
        defaultValue: '5',
        customPrompt: (prompt, defaultValue, hidden) =>
            'AAA$prompt:$defaultValue',
      );
      print('You are $age years old');
      completer.complete(true);
      return age;
    })
      ..send('6')
      ..run();

    await completer.future;
  });
}
