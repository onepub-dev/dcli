import '../settings.dart';
import '../util/wait_for_ex.dart';

import 'dshell_function.dart';

/// sleeps for the provided [duration] of the given [interval].
///
/// ```dart
/// sleep(2);
///
/// sleep(2, interval=Interval.minutes);
/// ```
///
/// The [interval] defaults to seconds.
///
/// If the duration is 0 or less sleep returns immediately.
void sleep(int duration, {Interval interval = Interval.seconds}) =>
    _Sleep().sleep(duration, interval: interval);

/// Allows you to specify how the [duration] argument
/// to [sleep] is interpreted.
enum Interval {
  /// the [duration] argument is in seconds
  seconds,

  /// the [millseconds] argument is in seconds
  millseconds,

  /// the [minutes] argument is in seconds
  minutes
}

class _Sleep extends DShellFunction {
  void sleep(int duration, {Interval interval = Interval.seconds}) {
    Settings().verbose('sleep: duration: $duration interval: $interval');
    Duration _duration;
    switch (interval) {
      case Interval.seconds:
        _duration = Duration(seconds: duration);
        break;
      case Interval.millseconds:
        _duration = Duration(microseconds: duration);
        break;
      case Interval.minutes:
        _duration = Duration(minutes: duration);
        break;
    }

    waitForEx<void>(Future.delayed(_duration));
  }
}
