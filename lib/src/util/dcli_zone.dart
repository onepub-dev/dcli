import 'dart:async';

import 'progress.dart';
import 'runnable_process.dart';

/// callback used when overloadin [printerr] in a DCliZone.
typedef DCliZonePrintErr = void Function(String?);

/// This class is highly experimental - use at your own risk.
class DCliZone {
  /// Key to the overloading [printerr] function.
  static const String printerrKey = 'printerr';

  /// Run dcli code in a zone which traps calls to [print] and [printerr]
  /// redirecting them to the passed progress.
  Future<Progress> run<R>(R Function() body, {Progress? progress}) async {
    progress ??= Progress.devNull();

    /// overload printerr so we can trap it.
    final zoneValues = <String, DCliZonePrintErr>{
      'printerr': (line) {
        if (line != null) {
          progress!.addToStderr(line);
        }
      }
    };

    // ignore: flutter_style_todos
    /// TODO: we need to some how await this.
    runZonedGuarded(body, (e, st) {},
        zoneValues: zoneValues,
        zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) => progress!.addToStdout(line)));

    return progress;
  }
}
