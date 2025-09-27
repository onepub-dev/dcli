/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io' as io;

import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';

/// sleeps for the provided [duration] of the given [interval].
///
/// WARINING: call this function will stop all async code from
/// running. This is a change from 3.x and previous version of dcli.
/// Use [sleepAsync] if you need async code to keep running.
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
///
/// See: [sleepAsync]
///
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

/// sleeps for the provided [duration] of the given [interval].
///
/// ```dart
/// sleepAsync(2);
///
/// sleepAsync(2, interval=Interval.minutes);
/// ```
///
/// The [interval] defaults to seconds.
///
/// If the duration is 0 or less sleep returns immediately.
///
/// See: [sleep]
///
Future<void> sleepAsync(int duration, {Interval interval = Interval.seconds}) =>
    _Sleep().sleepAsync(duration, interval: interval);

class _Sleep extends core.DCliFunction {
  void sleep(int duration, {Interval interval = Interval.seconds}) {
    verbose(() => 'sleep: duration: $duration interval: $interval');
    late Duration duration0;
    switch (interval) {
      case Interval.hours:
        duration0 = Duration(hours: duration);
      case Interval.seconds:
        duration0 = Duration(seconds: duration);
      case Interval.milliseconds:
        duration0 = Duration(milliseconds: duration);
      case Interval.minutes:
        duration0 = Duration(minutes: duration);
    }

    io.sleep(duration0);
  }

  Future<void> sleepAsync(int duration,
      {Interval interval = Interval.seconds}) async {
    verbose(() => 'sleep: duration: $duration interval: $interval');
    late Duration duration0;
    switch (interval) {
      case Interval.hours:
        duration0 = Duration(hours: duration);
      case Interval.seconds:
        duration0 = Duration(seconds: duration);
      case Interval.milliseconds:
        duration0 = Duration(milliseconds: duration);
      case Interval.minutes:
        duration0 = Duration(minutes: duration);
    }

    await Future.delayed(duration0, () {});
  }
}
