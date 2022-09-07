/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import 'progress.dart';
import 'runnable_process.dart';

/// callback used when overloadin [printerr] in a DCliZone.
typedef CaptureZonePrintErr = void Function(String?);

/// This class is highly experimental - use at your own risk.
/// It is designed to capture any output to print or printerr
/// within the scope of the callback.
/// Key to the overloading [printerr] function.
const String capturePrinterrKey = 'printerr';

/// Run code in a zone which traps calls to [print] and [printerr]
/// redirecting them to the passed progress.
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

  return progress;
}
