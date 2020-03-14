import '../util/wait_for_ex.dart';

import '../settings.dart';

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
    Sleep().sleep(duration, interval: interval);

enum Interval { seconds, millseconds, minutes }

class Sleep extends DShellFunction {
  void sleep(int duration, {Interval interval = Interval.seconds}) {
      Settings().verbose('sleep: duration: ${duration} interval: $interval');
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
