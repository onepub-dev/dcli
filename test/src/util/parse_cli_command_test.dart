@Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/functions/pwd.dart';

import 'package:dcli/src/script/command_line_runner.dart';
import 'package:dcli/src/util/parse_cli_command.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  group('ParseCLICommand', () {
    test('empty string', () {
      const test = '';

      expect(() => ParsedCliCommand(test, pwd),
          throwsA(const TypeMatcher<InvalidArguments>()));
    });
    test('a', () {
      const test = 'a';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(<String>[]));
    });

    test('ab', () {
      const test = 'ab';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('ab'));
    });

    test('a b c', () {
      const test = 'a b c';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('aa bb cc', () {
      const test = 'aa bb cc';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('aa'));
      expect(parsed.args, equals(['bb', 'cc']));
    });

    test('a  b  c', () {
      const test = 'a  b  c';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('a  "b"  "c1"', () {
      const test = 'a  "b"  "c1"';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c1']));
    });

    test('git log --pretty=format:"%s" v1.0.45', () {
      const test = 'git log --pretty=format:"%s" v1.0.45';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['log', '--pretty=format:%s', 'v1.0.45']));
    });

    test('ssh with quoted args', () {
      const command =
          'mkdir -p  /tmp/etc/openvpn; sudo cp -R /etc/openvpn/* /tmp/etc/openvpn';

      final cmdArgs = <String>[];
      cmdArgs.clear();
      cmdArgs.add('-t');
      cmdArgs.add('bilby.clouddialer.com.au');
      cmdArgs.add("'echo abc123 | sudo -S  $command'");

      final parsed = ParsedCliCommand.fromParsed('ssh', cmdArgs, pwd);

      expect(parsed.cmd, equals('ssh'));
      expect(
          parsed.args,
          equals([
            '-t',
            'bilby.clouddialer.com.au',
            'echo abc123 | sudo -S  $command'
          ]));
    });
  });

  group('Glob expansion', () {
    test('No expansion', () {
// var cmd = 'docker run   --network host   dcli:docker_dev_cli   -it --volume $HOME:/me --entrypoint /bin/bash';
    });
  });

  test('linux/macos', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          unorderedEquals(<String>[
            'fred.jpg',
            'one.jpg',
            'fred.png',
          ]));
    });
  }, onPlatform: <String, Skip>{
    'windows': const Skip("Powershell doesn't do glob expansion")
  });

  test('.*', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls .*', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(parsed.args, unorderedEquals(<String>['.hidden', '.two.txt']));
    });
  }, onPlatform: <String, Skip>{
    'windows': const Skip("Powershell doesn't do glob expansion")
  });

  test('invalid/.*', () {
    TestFileSystem().withinZone((fs) {
      expect(() => ParsedCliCommand('ls invalid/.*', fs.top),
          throwsA(const TypeMatcher<FileSystemException>()));
    });
  }, onPlatform: <String, Skip>{
    'windows': const Skip("Powershell doesn't do glob expansion")
  });

  test('valid/.*', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls middle/.*', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(parsed.args,
          unorderedEquals(<String>['middle/.hidden', 'middle/.four.txt']));
    });
  }, onPlatform: <String, Skip>{
    'windows': const Skip("Powershell doesn't do glob expansion")
  });

  test('alternate working directory', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls *.txt *.jpg', fs.middle);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          unorderedEquals(<String>[
            'three.txt',
            'four.txt',
            'two.jpg',
          ]));
    });
  }, onPlatform: <String, Skip>{
    'windows': const Skip("Powershell doesn't do glob expansion")
  });

  test('valid non-local path', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls middle/*.txt', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          unorderedEquals(<String>[
            'middle/three.txt',
            'middle/four.txt',
          ]));
    });
  });

  test('invalid absolute path/*', () {
    TestFileSystem().withinZone((fs) {
      expect(() => ParsedCliCommand('ls /git/dcli/*', fs.top),
          throwsA(const TypeMatcher<FileSystemException>()));
    });
  });

  test('valid absolute path/*', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls ${join(fs.top, '*.txt')}', fs.middle);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          unorderedEquals(
              <String>[join(fs.top, 'one.txt'), join(fs.top, 'two.txt')]));
    });
  });

  test('windows', () {
    TestFileSystem().withinZone((fs) {
      final parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(parsed.args, equals(['*.jpg', '*.png']));
    });
  }, onPlatform: <String, Skip>{
    'posix': const Skip('posix systems do glob expansion'),
  });

  test('Quote handling', () {
    const cmd = '''
docker 
      exec
      -it 
      XXXXXX
      mysql
      --user=root
      --password=password
      --host=slayer
      --port=3306
      -e
      "CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dcli.* TO 'me'@'slayer';"
      ''';

    final parsed = ParsedCliCommand(cmd.replaceAll('\n', ' '), pwd);

    expect(parsed.cmd, equals('docker'));
    expect(parsed.args.length, equals(10));
    expect(parsed.args[0], equals('''exec'''));
    expect(parsed.args[1], equals('''-it'''));
    expect(parsed.args[2], equals('''XXXXXX'''));
    expect(parsed.args[3], equals('''mysql'''));
    expect(parsed.args[4], equals('''--user=root'''));
    expect(parsed.args[5], equals('''--password=password'''));
    expect(parsed.args[6], equals('''--host=slayer'''));
    expect(parsed.args[7], equals('''--port=3306'''));
    expect(parsed.args[8], equals('''-e'''));
    expect(
        parsed.args[9],
        equals(
            '''CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dcli.* TO 'me'@'slayer';'''));
  });
}
