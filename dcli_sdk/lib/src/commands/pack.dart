/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:scope/scope.dart';

import '../script/flag.dart';
import '../util/exceptions.dart';
import 'commands.dart';

/// Generates a registry and independently compressed resource part classes.
/// Scans resource/ and externals configured in tool/dcli/pack.yaml, writing
/// lib/src/dcli/resource/generated/. Each part holds at most 256 KiB of raw data.
/// Applications unpack resources through the generated registry.
class PackCommand extends Command {
  static const _commandName = 'pack';

  ///
  PackCommand() : super(_commandName);

  /// [arguments] contains path to clean
  /// @Throwing(InvalidCommandArgumentException)
  @override
  Future<int> run(List<Flag> selectedFlags, List<String> arguments) async {
    final scope = Scope()
      ..value(
        Resources.scopeKeyProjectRoot,
        DartProject.fromPath(pwd).pathToProjectRoot,
      );
    return scope.runSync<int>(_pack);
  }

  int _pack() {
    if (!exists(Resources().resourceRoot) &&
        !exists(Resources.pathToPackYaml)) {
      throw InvalidCommandArgumentException(
        'Unable to pack resources as neither a resource directory at '
        '${Resources().resourceRoot}'
        ' nor ${Resources.pathToPackYaml} exists.',
      );
    }

    if (!exists(Resources().resourceRoot)) {
      print(
        orange(
          '${Resources().resourceRoot} not found. '
          'Only external resources will be packed',
        ),
      );
    }

    try {
      Resources().pack();
    } on ResourceException catch (e) {
      printerr(red(e.message));
      return 1;
    }
    return 0;
  }

  @override
  String usage() => '''pack''';

  /// @Throwing(ArgumentError)
  /// @Throwing(PathException)
  @override
  String description({bool extended = false}) {
    var desc = '''
Pack all files under the 'resource' directory or
   those listed in pack.yaml into compressed part classes for runtime unpacking.''';
    if (extended) {
      desc += '''
      
To include resources located outside your package directory create tool/dcli/pack.yaml.
https://dcli.onepub.dev/dcli-api/assets#external-resources
''';
    }
    return desc;
  }

  @override
  List<String> completion(String word) => [word];

  @override
  List<Flag> flags() => [];
}
