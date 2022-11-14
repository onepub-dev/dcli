import 'dart:async';

import '../../dcli.dart';

/// callback used when overloadin [printerr] in a DCliZone.
typedef DCliZonePrintErr = void Function(String?);

/// This class is highly experimental - use at your own risk.
class DCliZone {
  /// Key to the overloading [printerr] function.
  static const String printerrKey = 'printerr';

  /// Run dcli code in a zone which traps calls to [print] and [printerr]
  /// redirecting them to the passed progress.
  Future<Progress> run<R>(Future<R> Function() body,
      {Progress? progress}) async {
    progress ??= Progress.devNull();

    /// overload printerr so we can trap it.
    final zoneValues = <String, DCliZonePrintErr>{
      'printerr': (line) {
        if (line != null) {
          progress!.addToStderr(line);
        }
      }
    };

    final zoneCompleter = Completer<R>();
    runZonedGuarded(
      () => _body(body, zoneCompleter),
      (e, st) {},
      zoneValues: zoneValues,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => progress!.addToStdout(line),
      ),
    );

    await zoneCompleter.future;

    // give the stream listeners a chance to run.
    // may not be necessary not that we have the
    // above waitForEx but until then...
    await Future.value(1);

    return progress;
  }

  void _body<R>(R Function() body, Completer<R> zoneCompleter) {
    final r = body();

    zoneCompleter.complete(r);
  }
}
