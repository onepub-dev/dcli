import 'package:scope/scope.dart';

class UnitTestController {
  /// We inject this key when running a unit test so that dcli
  /// code can be 'unit test' aware and modify its behaviour
  /// to be unit test friendly.
  static final unitTestingKey =
      ScopeKey<bool>.withDefault(false, 'Running in a unit test');

  /// Run code within a unit test
  /// Certain DCli functions modify there behaviour
  /// when run within a unit test.
  /// The rely on this scope to determine if they are
  /// in a unit test.
  /// @Throwing(CircularDependencyException)
  /// @Throwing(DuplicateDependencyException)
  /// @Throwing(MissingDependencyException)
  static Future<void> withUnitTest(void Function() action) async {
    final scope = Scope()..value(unitTestingKey, true);
    await scope.run(() async => action());
  }
}
