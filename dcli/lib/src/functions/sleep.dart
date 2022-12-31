/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

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

/// Allows you to specify how the duration argument
/// to [sleep] is interpreted.
enum Interval {
  /// the duration argument is in hours.
  hours,

  /// the duration argument is in seconds
  seconds,

  /// the duration argument is in seconds
  milliseconds,

  /// the duration argument is in seconds
  minutes
}

class _Sleep extends core.DCliFunction {
  void sleep(int duration, {Interval interval = Interval.seconds}) {
    verbose(() => 'sleep: duration: $duration interval: $interval');
    late Duration duration0;
    switch (interval) {
      case Interval.hours:
        duration0 = Duration(hours: duration);
        break;
      case Interval.seconds:
        duration0 = Duration(seconds: duration);
        break;
      case Interval.milliseconds:
        duration0 = Duration(milliseconds: duration);
        break;
      case Interval.minutes:
        duration0 = Duration(minutes: duration);
        break;
    }

    waitForEx<void>(Future.delayed(duration0));
  }
}
