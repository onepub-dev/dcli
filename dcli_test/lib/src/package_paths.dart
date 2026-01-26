import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// Absolute paths to each of the packages so we can reference them
/// during testing.

final String pathToPackageDCli =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli');

final String pathToPackageCommon =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_common');

final String pathToPackageCore =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_core');

final String pathToPackageInput =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_input');

final String pathToPackageSdk =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_sdk');

final String pathToPackageTerminal =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_terminal');

final String pathToPackageTest =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_test');

final String pathToPackageUnitTester =
    join(dirname(DartProject.self.pathToProjectRoot), 'dcli_unit_tester');
