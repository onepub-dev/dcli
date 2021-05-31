import 'dart:io';

import 'package:meta/meta.dart';

/// This class wraps Platform so we are able to mock the Platform class
/// in unit tests.

class PlatformWrapper {
  /// Factory ctor
  factory PlatformWrapper() => _self;

  PlatformWrapper._internal();
  static PlatformWrapper _self = PlatformWrapper._internal();

  /// True if we are running on windows
  bool get isWindows => Platform.isWindows;

  /// For testing only
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set mock(PlatformWrapper platformMock) {
    _self = platformMock;
  }
}
