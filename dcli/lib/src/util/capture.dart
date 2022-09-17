/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:io';

import '../../dcli.dart';
import '../puppet/stdin.dart';
import '../puppet/stdout.dart';

/// callback used when overloadin [printerr] in a DCliZone.
typedef CaptureZonePrintErr = void Function(String?);

/// This class is highly experimental - use at your own risk.
/// It is designed to capture any output to print or printerr
/// within the scope of the callback.
/// Key to the overloading [printerr] function.
const String capturePrinterrKey = 'printerr';

/// Run code in a zone which traps calls to [print] and [printerr]
/// redirecting them to the passed progress.
/// If no [progress] is passed then then both print and printerr
/// output is surpressed.
Progress capture<R>(R Function() action, {Progress? progress}) {
  progress ??= Progress.devNull();

  /// overload printerr so we can trap it.
  final zoneValues = <String, CaptureZonePrintErr>{
    'printerr': (line) {
      if (line != null) {
        progress!.addToStderr(line);
      }
    }
  };

  runZonedGuarded(
    action,
    (e, st) {},
    zoneValues: zoneValues,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => progress!.addToStdout(line),
    ),
  );

  // give the stream listeners a chance to run.
  waitForEx(Future.value(1));

  return progress;
}

// void interact(String expected, void Function() action) {

//   var inStream = StreamController<List<int>>(); // StreamConsumer
//   var outStream = StreamController<List<int>>(); // Stream
//   var errStream = StreamController<List<int>>();

//   stdin;

//   IOOverrides.runZoned(() => action,
//   stdin: () => Stdin._(inStream.stream),
//   stdout: ,
//   stderr: );

// }

void test() {
  Puppet(spawn: () {
    final age = ask(
      'How old are you',
      defaultValue: '5',
      customPrompt: (prompt, defaultValue, {hidden = false}) =>
          'AAA$prompt:$defaultValue',
    );
    print('You are $age years old');
  })
    ..expect('AAAHow old ar you:5')
    ..send('6')
    ..expect('You are 6 years old');
}

// or Interact
class Puppet<T> {
  Puppet({required this.spawn});
  T Function() spawn;

  void _run() {
    IOOverrides.runZoned(() => spawn,
        stdin: PuppetStdin.new,
        stdout: () => PuppetStdout(stdout),
        stderr: () => PuppetStdout(stderr));
  }

  void expect(String expected) {}

  void send(String s) {}
}
