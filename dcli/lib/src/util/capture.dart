import 'dart:async';

import '../../dcli.dart';
import '../progress/progress_impl.dart';

/// callback used when overloading [printerr] in a DCliZone.
typedef CaptureZonePrintErr = void Function(String);

/// This class is highly experimental - use at your own risk.
/// It is designed to capture any output to print or printerr
/// within the scope of the callback.
/// Key to the overloading [printerr] function.

/// Key to the overloading [printerr] function.
const String capturePrinterrKey = 'printerr';

/// Run code in a zone which traps calls to [print] and [printerr]
/// redirecting them to the passed progress.
/// If no [progress] is passed then the output from print and printerr
/// is surpressed.
Future<Progress> capture<R>(Future<R> Function() action,
    {Progress? progress}) async {
  final progressImpl = (progress ?? Progress.devNull()) as ProgressImpl;

  /// overload printerr so we can trap it.
  final zoneValues = <String, CaptureZonePrintErr>{
    'printerr': (line) {
      progressImpl.addToStderr('$line\n'.codeUnits);
    }
  };

  final zoneCompleter = Completer<R>();
  runZonedGuarded(
    /// runZone takes a sync method but we need
    /// an async body s we can await the real [body]
    /// method in [_body]
    /// We then use the zoneCompleter to wait for the body to complete.
    () => _unawaited(_body(action, zoneCompleter)),
    (e, st) {
      if (!zoneCompleter.isCompleted) {
        zoneCompleter.complete(null);
      }
    },
    zoneValues: zoneValues,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) =>
          progressImpl.addToStdout('$line\n'.codeUnits),
    ),
  );

  await zoneCompleter.future;

  // give the stream listeners a chance to flush.
  await _flush(progressImpl);

  return progressImpl as Progress;
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

// saves importing pedantic.
void _unawaited(Future<void>? future) {}

Future<void> _flush(ProgressImpl progress) async {
  /// give the event queue a chance to run.
  await Future.value(1);
  // scheduleMicrotask(() {});
  progress.close();
  // scheduleMicrotask(() {});
  await Future.value(1);
}
