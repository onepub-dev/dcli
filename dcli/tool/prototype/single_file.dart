import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/packed_bundle_builder.dart';
import 'package:path/path.dart' as p;

/// Prototype: pack a Dart CLI bundle into a self-extracting native launcher.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('build-dir', help: 'Keep generated sources and metrics here.')
    ..addFlag('help', abbr: 'h', negatable: false);
  final args = parser.parse(arguments);
  if (args['help'] as bool || args.rest.length != 2) {
    print(
      'Usage: dart run tool/prototype/single_file.dart '
      '[--build-dir <new-directory>] <bundle-directory> <output-executable>',
    );
    print(parser.usage);
    exitCode = args['help'] as bool ? 0 : 64;
    return;
  }
  final input = Directory(p.absolute(args.rest[0]));
  final output = File(p.absolute(args.rest[1]));
  if (p.isWithin(input.path, output.path)) {
    throw ArgumentError('Output must be outside the input bundle.');
  }
  final files = input.listSync(recursive: true, followLinks: false);
  if (File(p.join(input.path, '.complete')).existsSync()) {
    throw ArgumentError('The name .complete is reserved for the cache marker.');
  }
  if (files.any((file) => file is Link)) {
    throw ArgumentError(
      'Prototype bundles must contain regular files, not links.',
    );
  }
  final executables = Directory(
    p.join(input.path, 'bin'),
  ).listSync().whereType<File>().toList();
  if (executables.length != 1) {
    throw ArgumentError('Expected exactly one executable in bundle/bin.');
  }
  final inputBytes = files.whereType<File>().fold<int>(
    0,
    (total, file) => total + file.lengthSync(),
  );
  final keep = args['build-dir'] as String?;
  final build = keep == null
      ? Directory.systemTemp.createTempSync('dcli-single-file-')
      : Directory(p.absolute(keep));
  if (keep != null) {
    if (build.existsSync()) {
      throw ArgumentError('Build directory must be new.');
    }
    if (p.isWithin(input.path, build.path)) {
      throw ArgumentError('Build directory must be outside the input bundle.');
    }
    build.createSync(recursive: true);
  }
  final elapsed = Stopwatch()..start();
  try {
    final launcher = PackedBundleBuilder.generate(
      input.path,
      build.path,
      p.basename(executables.single.path),
    );
    final generatedBytes = build
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .fold<int>(0, (bytes, file) => bytes + file.lengthSync());
    final compileTime = Stopwatch()..start();
    final candidate = p.join(
      build.path,
      Platform.isWindows ? 'packed.exe' : 'packed',
    );
    final process = await Process.start(
      Platform.resolvedExecutable,
      [
        '--suppress-analytics',
        'compile',
        'exe',
        launcher,
        '--packages=${p.join(build.path, 'package_config.json')}',
        '--output=$candidate',
      ],
      workingDirectory: build.path,
      mode: ProcessStartMode.inheritStdio,
    );
    final result = await process.exitCode;
    compileTime.stop();
    if (result != 0) {
      exitCode = result;
      return;
    }
    output.parent.createSync(recursive: true);
    move(candidate, output.path, overwrite: true);
    final metrics = {
      'inputBytes': inputBytes,
      'generatedSourceBytes': generatedBytes,
      'executableBytes': output.lengthSync(),
      'compileMilliseconds': compileTime.elapsedMilliseconds,
      'totalMilliseconds': elapsed.elapsedMilliseconds,
      'executable': output.path,
    };
    if (keep != null) {
      File(
        p.join(build.path, 'metrics.json'),
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(metrics));
    }
    print('Executable: ${output.path}');
    print(
      'Packed ${files.whereType<File>().length} files: '
      '$inputBytes input bytes, '
      '$generatedBytes source bytes, ${output.lengthSync()} executable bytes.',
    );
    print('Compile: ${compileTime.elapsedMilliseconds} ms.');
    if (keep != null) {
      print('Generated sources and metrics: ${build.path}');
    }
  } finally {
    if (keep == null) {
      build.deleteSync(recursive: true);
    }
  }
}
