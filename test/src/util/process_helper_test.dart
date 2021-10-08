@Timeout(Duration(minutes: 5))
import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
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
      /// as we are in a dart unit test dart should be running.
      final darts = ProcessHelper().getProcessesByName('dart');
      expect(darts.isNotEmpty, isTrue);
      for (final process in darts) {
        expect(process.name, equals('dart'));
      }
    });

    test('unknown process', () {
      /// try do find a process that isn't running.
      final darts = ProcessHelper().getProcessesByName('a;ljfasahaoi8w3dvaadk');
      expect(darts.isEmpty, isTrue);
    });
  });

  // test('ProcessHelper', () {
  //   TestFileSystem().withinZone((fs) async {

  //     ProcessHelper().getProcessName(pid);

  //   });
  // });
}
