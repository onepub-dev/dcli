import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' as path;
import 'package:posix/posix.dart' as posix;
import 'package:test/test.dart';

void main() {
  test('permission checks do not run groups from the inspected PATH', () {
    final directory = Directory.systemTemp.createTempSync('dcli permission ');
    addTearDown(() => directory.deleteSync(recursive: true));
    final candidate = File(path.join(directory.path, 'candidate'))
      ..writeAsStringSync('not executed');
    expect(Process.runSync('chmod', ['750', candidate.path]).exitCode, 0);
    Link(path.join(directory.path, 'groups')).createSync('/usr/bin/false');

    core.withEnvironment(() {
      expect(isExecutable(candidate.path), isTrue);
      expect(isReadable(candidate.path), isTrue);
      expect(isWritable(candidate.path), isTrue);
    }, environment: {'PATH': '${directory.path}:/usr/bin:/bin'});
  }, skip: Platform.isWindows || posix.geteuid() == 0);

  test('owner permissions take precedence over other bits', () {
    final directory = Directory.systemTemp.createTempSync('dcli mode ');
    addTearDown(() => directory.deleteSync(recursive: true));
    final candidate = File(path.join(directory.path, 'candidate'))
      ..writeAsStringSync('not executed');
    expect(Process.runSync('chmod', ['601', candidate.path]).exitCode, 0);

    expect(isExecutable(candidate.path), isFalse);
    expect(isReadable(candidate.path), isTrue);
    expect(isWritable(candidate.path), isTrue);
  }, skip: Platform.isWindows || posix.geteuid() == 0);

  test('group membership uses native group IDs', () {
    final primary = posix.getgrgid(posix.getegid()).name;
    expect(isMemberOfGroup(primary), isTrue);
    expect(isMemberOfGroup('nonexistent-dcli-test-group'), isFalse);
  }, skip: Platform.isWindows);

  test('missing paths keep the StatException contract', () {
    final directory = Directory.systemTemp.createTempSync('dcli missing ');
    addTearDown(() => directory.deleteSync(recursive: true));
    final missing = path.join(directory.path, 'missing');

    expect(() => isReadable(missing), throwsA(isA<posix.StatException>()));
    expect(() => isWritable(missing), throwsA(isA<posix.StatException>()));
    expect(() => isExecutable(missing), throwsA(isA<posix.StatException>()));
  }, skip: Platform.isWindows);
}
