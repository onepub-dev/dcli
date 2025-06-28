import 'dart:io';

/// A script to replace the existing copyright header in Dart files
/// with an MIT license header noting S. Brett Sutton as the copyright holder.
///
/// Usage:
///   dart replace_copyright_header.dart [directory]
///
/// If no directory is provided, the script runs in the current working directory.

void main(List<String> args) {
  // Determine the target directory: CLI arg or current directory
  final directory = args.isNotEmpty ? Directory(args[0]) : Directory.current;

  // Recursively list all Dart files
  final dartFiles = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  // Regex to match the existing copyright block at the top of the file
  final headerRegex = RegExp(r'^/\*[\s\S]*?\*/\s*');

  // Build the new MIT license header, dynamically including the current year
  final year = DateTime.now().year;
  final newHeader = '''
/*
 * Copyright (c) $year S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

''';

  // Process each Dart file
  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final updatedContent = content.replaceFirst(headerRegex, newHeader);
    if (content != updatedContent) {
      file.writeAsStringSync(updatedContent);
      print('Updated header in: ${file.path}');
    }
  }
}
