import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dartcli/move_command.dart';
import 'package:dartcli/patch_command.dart';

@Timeout(Duration(seconds: 600))
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

void main() {
  group('File rename:', () {
    test('rename file', () async {
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        //  "--debug",
        "a_command2.dart",
        "a_command.dart"
      ]);
      expect(success, true);
    });

    test('rename file back', () async {
      // move it back
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        // "--debug",
        "a_command.dart",
        "a_command2.dart"
      ]);
      expect(success, true);
    });
  });

  group('Move File To Directory', () {
    test('move file to directory', () async {
      // move file to directory
      bool success = await run([
        "move", "--root", "./test/data/", //"--debug"
        "yaml_me.dart", "util"
      ]);
      expect(success, true);
    });

    test('Now move it back', () async {
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        // "--debug",
        "util/yaml_me.dart",
        "."
      ]);
      expect(success, true);
    });
  });

  group("Move Directory to Directory", () {
    test('util to other', () async {
      bool success = await run([
        "move", "--root", "./test/data/",
        // "--debug",
        "util", "other"
      ]);
      expect(success, true);
    });

    test('other to util', () async {
      bool success = await run([
        "move", "--root", "./test/data/",
        // "--debug",
        "other", "util"
      ]);
      expect(success, true);
    });
  });

  group('Move Directory to File', () {
    test('Util to other.dart', () async {
      bool success = await run([
        "move", "--root", "./test/data/",
        // "--debug",
        "util", "other.dart"
      ]);
      expect(success, false);
    });
  });

  group('Rename a file', () {
    test("Rename A->A2", () async {
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        //"--debug",
        "a_command.dart",
        "a_command2.dart"
      ]);
      expect(success, true);
    });

    test("Rename A2->A", () async {
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        //"--debug",
        "a_command2.dart",
        "a_command.dart"
      ]);
      expect(success, true);
    });
  });

  group('Move File to directory/file', () {
    test("Yaml_me.dart to util", () async {
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        // "--debug",
        "yaml_me.dart",
        "util/yaml_me.dart"
      ]);
      expect(success, true);
    });

    test("Move Yaml from util", () async {
      bool success = await run([
        "move",
        "--root",
        "./test/data/",
        // "--debug",
        "util/yaml_me.dart",
        "yaml_me.dart"
      ]);
      expect(success, true);
    });
  });

  test("Move Service Locator", () async {
    bool success = await run([
      "move",
      "--root",
      "/home/bsutton/git/squarephone_app",
      //"--debug",
      "service_locator.dart",
      "app/service_locator.dart"
    ]);
    expect(success, true);
  });
}

Future<bool> run(List<String> arguments) async {
  bool success = false;
  String cwd = p.current;
  try {
    print(arguments);
    CommandRunner<void> runner =
        CommandRunner("drtimport", "dart import management");

    runner.addCommand(MoveCommand());
    runner.addCommand(PatchCommand());

    await runner.run(arguments);
    success = true;
  } finally {
    // restore the current working directory.
    Directory.current = cwd;
  }
  return success;
}
