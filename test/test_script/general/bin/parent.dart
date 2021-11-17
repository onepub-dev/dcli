// ignore_for_file: deprecated_member_use

import 'dart:cli';
import 'dart:io';

void main() {
  print('parent hasTerminal=${stdin.hasTerminal}');

  print('run child.dart');
  var process = waitFor<Process>(Process.start('dart', ['./child.dart'],
      mode: ProcessStartMode.inheritStdio));
  waitFor<int>(process.exitCode);

  print('run child exe');
  process = waitFor<Process>(
      Process.start('child', [], mode: ProcessStartMode.inheritStdio));

  waitFor<int>(process.exitCode);
}
