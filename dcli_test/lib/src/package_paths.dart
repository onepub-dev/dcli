import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// Absolute paths to each of the packages so we can reference them
/// during testing.

final pathToPackageDCli =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli');

final pathToPackageCommon =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_common');

final pathToPackageCore =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_core');

final pathToPackageInput =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_input');

final pathToPackageSdk =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_sdk');

final pathToPackageTerminal =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_terminal');

final pathToPackageTest =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_test');

final pathToPackageUnitTester =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_unit_tester');
