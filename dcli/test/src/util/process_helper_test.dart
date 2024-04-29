@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/process_helper.dart';
import 'package:test/test.dart';

void main() {
  test('ProcessHelper', () {
    expect(ProcessHelper().getProcessName(pid), isNot(equals('unknown')));
  });

  test('ProcessHelper - parent pid', () {
    final parent = ProcessHelper().getParentPID(pid);
    expect(parent, isNot(equals(-1)));
    expect(parent, isNot(equals(pid)));
  });

  test('ProcessHelper - isRunning', () {
    expect(ProcessHelper().isRunning(pid), equals(true));
  });

  test('Get running processes', () {
    final processes = ProcessHelper().getProcesses();

    /// the list should container our details.
    expect(processes.contains(ProcessDetails(pid, '', '')), isTrue);
  });

  group('getProcessByName', () {
    test('process exists', () {
      final exeName = DartSdk.dartExeName;

      /// as we are in a dart unit test dart should be running.
      final darts = ProcessHelper().getProcessesByName(exeName);
      expect(darts.isNotEmpty, isTrue);
      for (final process in darts) {
        expect(process.name, equals(exeName));
      }
    });

    test('unknown process', () {
      /// try do find a process that isn't running.
      final darts = ProcessHelper().getProcessesByName('a;ljfasahaoi8w3dvaadk');
      expect(darts.isEmpty, isTrue);
    });
  });

  test('parse status line', () {
    expect(parseProcessLine('Name:	dart:ihserver.d'),
        equals(('Name', 'dart:ihserver.d')));

    expect(parseProcessLine('Umask:	0022'), equals(('Umask', '0022')));

    expect(parseProcessLine('State:	S (sleeping)'),
        equals(('State', 'S (sleeping)')));

    expect(parseProcessLine('Empty:'), equals(('Empty', '')));

    expect(parseProcessLine('Empty: '), equals(('Empty', '')));

    expect(parseProcessLine('NoColon'), equals(('NoColon', '')));

    expect(parseProcessLine('VmSize:	 1012072 kB'),
        equals(('VmSize', '1012072 kB')));
  });

  // test('ProcessHelper', () {
  //   TestFileSystem().withinZone((fs) async {

  //     ProcessHelper().getProcessName(pid);

  //   });
  // });

  test('line splitter', () {
    const process = r'C:\windows\system32\svchost.exe 1104 2128';

    var r = ProcessHelper.parseWMICLine(process);

    expect(r.exe, equals(r'C:\windows\system32\svchost.exe'));
    expect(r.parentPid, equals(1104));
    expect(r.processPid, equals(2128));

    /// process with space in its name.
    const process2 = r'C:\windows\system32\svchost name.exe 1104 2128';

    r = ProcessHelper.parseWMICLine(process2);

    expect(r.exe, equals(r'C:\windows\system32\svchost name.exe'));
    expect(r.parentPid, equals(1104));
    expect(r.processPid, equals(2128));
  });
}
