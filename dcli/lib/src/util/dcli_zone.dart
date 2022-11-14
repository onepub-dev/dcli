import 'dart:async';

import 'package:pedantic/pedantic.dart';

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
      /// runZone takes a sync method but we need
      /// an async body s we can await the real [body]
      /// method in [_body]
      /// We then use the zoneCompleter to wait for the body to complete.
      () => unawaited(_body(body, zoneCompleter)),
      (e, st) {
        if (!zoneCompleter.isCompleted) {
          zoneCompleter.complete(null);
        }
      },
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

  Future<void> _body<R>(
      Future<R> Function() body, Completer<R> zoneCompleter) async {
    R r;
    try {
      r = await body();
      zoneCompleter.complete(r);
      // ignore: avoid_catches_without_on_clauses
    } catch (_, __) {
      zoneCompleter.complete(null);
      rethrow;
    }
  }
}
