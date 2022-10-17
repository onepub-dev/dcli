import 'package:dcli_core/dcli_core.dart' as core;
import '../util/wait_for_ex.dart';

/// Creates a environment that is contained to the scope
/// of the [callback] method.
///
/// The [environment] map is merged with the current [core.env] and
/// injected into the [callback]'s scope.
///
/// Any changes to [core.env] within the scope of the callback
/// are only visible inside that scope and revert once [callback]
/// returns.
/// This is particularly useful for unit tests and running
/// a process that requires specific environment variables.
R withEnvironment<R>(R Function() callback,
    {required Map<String, String> environment}) {
      // ignore: discarded_futures
  final result = core.withEnvironment<R>(() => Future.value(callback()),
      environment: environment);

  return waitForEx(result);
}
