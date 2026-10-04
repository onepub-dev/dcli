import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory temporary;

  setUp(() {
    temporary = Directory.systemTemp.createTempSync('dcli native test ');
  });
  tearDown(() => temporary.deleteSync(recursive: true));

  void write(String path, String contents) {
    File(p.join(temporary.path, path))
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);
  }

  test('detects relative dependency hooks from a workspace configuration', () {
    write('app/bin/tool.dart', 'void main() {}');
    write(
      '.dart_tool/package_config.json',
      jsonEncode({
        'configVersion': 2,
        'packages': [
          {'name': 'native_dependency', 'rootUri': '../native dependency'},
        ],
      }),
    );
    final script = DartScript.fromFile(
      p.join(temporary.path, 'app', 'bin', 'tool.dart'),
    );
    expect(DartSdk().hasBuildHooks(script), isFalse);
    write('native dependency/hook/build.dart', 'void main() {}');
    expect(DartSdk().hasBuildHooks(script), isTrue);
  });

  test(
    'plain Dart compilation still produces a standalone executable',
    () async {
      write('plain/pubspec.yaml', '''
name: plain_compile_fixture
environment:
  sdk: '>=3.10.0 <4.0.0'
''');
      write('plain/tool.dart', "void main() => print('plain');");
      final project = p.join(temporary.path, 'plain');
      final pub = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: project);
      expect(pub.exitCode, 0, reason: '${pub.stdout}\n${pub.stderr}');
      final script = DartScript.fromFile(p.join(project, 'tool.dart'));
      expect(DartSdk().hasBuildHooks(script), isFalse);
      final compileOutput = await capture(() async {
        script.compile(workingDirectory: project);
      }, progress: Progress.capture());
      expect(
        compileOutput.lines,
        contains('  Executable: ${script.pathToExe}'),
      );
      expect(
        compileOutput.lines.any((line) => line.startsWith('Generated: ')),
        isFalse,
      );
      final result = await Process.run(
        script.pathToExe,
        [],
        workingDirectory: temporary.path,
      );
      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect('${result.stdout}'.trim(), 'plain');
      expect(Directory(p.join(temporary.path, 'lib')).existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test('installation renames and replaces an entire private bundle', () {
    write('source/tool', 'launcher');
    write('source/.tool.bundle/bin/tool', 'executable');
    write('source/.tool.bundle/lib/native.so', 'library');
    write('target/renamed', 'old launcher');
    write('target/.renamed.bundle/lib/obsolete.so', 'obsolete');
    write('target/.other.bundle/lib/native.so', 'other application');
    final compiled = CompiledExecutable(
      p.join(temporary.path, 'source', 'tool'),
      hasBundle: true,
    );
    final destination = p.join(temporary.path, 'target', 'renamed');
    expect(
      () => compiled.install(destination),
      throwsA(isA<InvalidArgumentException>()),
    );
    expect(File(destination).readAsStringSync(), 'old launcher');
    final installed = compiled.install(destination, overwrite: true);
    final reported = <String>[];
    installed.report(output: reported.add);
    expect(reported, contains('  Launcher: $destination'));
    expect(
      reported,
      contains(
        '  Executable: '
        '${p.join(temporary.path, 'target', '.renamed.bundle', 'bin', 'tool')}',
      ),
    );
    expect(
      reported,
      contains(
        '  Library: '
        '${p.join(temporary.path, 'target', '.renamed.bundle', 'lib', 'native.so')}',
      ),
    );
    expect(reported.join('\n'), isNot(contains('source/')));
    expect(File(destination).readAsStringSync(), 'launcher');
    expect(File(compiled.pathToExe).existsSync(), isFalse);
    expect(Directory(compiled.pathToBundle!).existsSync(), isFalse);
    final bundle = CompiledExecutable.bundlePath(destination);
    expect(File(p.join(bundle, 'bin/tool')).readAsStringSync(), 'executable');
    expect(File(p.join(bundle, 'lib/native.so')).readAsStringSync(), 'library');
    expect(File(p.join(bundle, 'lib/obsolete.so')).existsSync(), isFalse);
    expect(
      File(
        p.join(temporary.path, 'target/.other.bundle/lib/native.so'),
      ).readAsStringSync(),
      'other application',
    );
  });

  test(
    'native executable runs after compilation and relocation',
    () async {
      write('project/pubspec.yaml', '''
name: native_compile_fixture
environment:
  sdk: '>=3.10.0 <4.0.0'
dependencies:
  hooks: ^1.0.0
  code_assets: ^1.0.0
''');
      write('project/tool.dart', '''
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
@Native<Int32 Function()>(assetId: 'package:native_compile_fixture/answer.dart')
external int answer();
Future<void> main(List<String> args) async {
  if (args.contains('--wait')) {
    ProcessSignal.sigterm.watch().listen((_) => exit(37));
    print(pid);
    await Completer<void>().future;
  }
  print(jsonEncode({
    'answer': answer(), 'args': args, 'pid': pid,
    'cwd': Directory.current.path,
    'environment': Platform.environment['DCLI_LAUNCHER_TEST'],
    'stdin': stdin.readLineSync(),
  }));
  stderr.writeln('fixture stderr');
  exit(23);
}
''');
      write('project/answer.c', 'int answer(void) { return 42; }');
      write('project/hook/build.dart', r'''
import 'dart:io';
import 'package:hooks/hooks.dart';
import 'package:code_assets/code_assets.dart';
void main(List<String> args) async {
  await build(args, (input, output) async {
    final library = input.outputDirectory.resolve(
      Platform.isMacOS ? 'libanswer.dylib' : 'libanswer.so');
    final result = await Process.run('cc', [
      if (Platform.isMacOS) '-dynamiclib' else '-shared',
      '-fPIC', input.packageRoot.resolve('answer.c').toFilePath(),
      '-o', library.toFilePath(),
    ]);
    if (result.exitCode != 0) throw StateError('${result.stderr}');
    output.assets.code.add(CodeAsset(
      package: input.packageName,
      name: 'answer.dart',
      linkMode: DynamicLoadingBundled(),
      file: library,
    ));
  });
}
''');
      final project = p.join(temporary.path, 'project');
      final pub = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: project);
      expect(pub.exitCode, 0, reason: '${pub.stdout}\n${pub.stderr}');
      final script = DartScript.fromFile(p.join(project, 'tool.dart'));
      final compiled = DartSdk().runDartCompiler(
        script,
        pathToExe: script.exeName,
        workingDirectory: project,
      );
      expect(compiled.pathToExe, script.pathToExe);
      expect(compiled.hasBundle, isTrue);
      expect(compiled.pathToBundle, p.join(project, '.tool.bundle'));
      expect(
        File(
          p.join(compiled.pathToBundle!, 'bin', script.exeName),
        ).existsSync(),
        isTrue,
      );
      expect(Directory(p.join(temporary.path, 'lib')).existsSync(), isFalse);
      expect(Directory(p.join(project, 'lib')).existsSync(), isFalse);
      if (Platform.isLinux) {
        final magic = File(script.pathToExe).openSync();
        try {
          expect(magic.readSync(4), [0x7f, 0x45, 0x4c, 0x46]);
        } finally {
          magic.closeSync();
        }
      }
      final arguments = ['', 'two words', '"quotes"', r'$literal', 'héllo'];
      final cache = Directory(p.join(temporary.path, 'cache'));
      Future<void> verifyLauncher(
        String executable, {
        bool useDefaultCache = false,
      }) async {
        final process = await Process.start(
          executable,
          arguments,
          workingDirectory: temporary.path,
          environment: {
            'DCLI_LAUNCHER_TEST': 'inherited',
            'HOME': temporary.path,
            'USERPROFILE': temporary.path,
            'DCLI_BUNDLE_CACHE': useDefaultCache ? '' : cache.path,
            'DCLI_BUNDLE_VERBOSE': '1',
          },
        );
        final stdout = process.stdout.transform(utf8.decoder).join();
        final stderr = process.stderr.transform(utf8.decoder).join();
        process.stdin.writeln('piped input');
        await process.stdin.close();
        expect(await process.exitCode, 23, reason: await stderr);
        final output = jsonDecode(await stdout) as Map<String, dynamic>;
        expect(output['answer'], 42);
        expect(output['args'], arguments);
        expect(output['cwd'], temporary.resolveSymbolicLinksSync());
        expect(output['environment'], 'inherited');
        expect(output['stdin'], 'piped input');
        expect(output['pid'], process.pid);
        expect(await stderr, contains('fixture stderr'));
      }

      await verifyLauncher(script.pathToExe);
      final signalProcess = await Process.start(script.pathToExe, ['--wait']);
      try {
        final reportedPid = await signalProcess.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .first;
        expect(int.parse(reportedPid), signalProcess.pid);
        expect(signalProcess.kill(), isTrue);
        expect(
          await signalProcess.exitCode.timeout(const Duration(seconds: 5)),
          37,
        );
      } finally {
        signalProcess.kill(ProcessSignal.sigkill);
      }

      // A successful rebuild replaces the bundle, including obsolete files.
      final obsolete = File(p.join(compiled.pathToBundle!, 'lib', 'obsolete'))
        ..writeAsStringSync('old library');
      script.compile(workingDirectory: project);
      expect(obsolete.existsSync(), isFalse);
      await verifyLauncher(script.pathToExe);

      // Packed mode uses the same native application and no adjacent bundle.
      final packed = p.join(temporary.path, 'packed-tool');
      final packedResult = DartSdk().runDartCompiler(
        script,
        pathToExe: packed,
        workingDirectory: project,
        packed: true,
      );
      expect(packedResult.isPacked, isTrue);
      expect(packedResult.hasBundle, isFalse);
      expect(
        Directory(CompiledExecutable.bundlePath(packed)).existsSync(),
        isFalse,
      );
      await verifyLauncher(packed, useDefaultCache: true);
      final defaultCache = Directory(
        p.join(temporary.path, '.dcli', 'cache', 'bundles'),
      );
      expect(
        defaultCache
            .listSync(recursive: true)
            .whereType<File>()
            .any((file) => p.basename(file.path) == '.complete'),
        isTrue,
      );
      await verifyLauncher(packed);
      final marker =
          cache
              .listSync(recursive: true)
              .whereType<File>()
              .singleWhere((file) => p.basename(file.path) == '.complete')
            ..setLastModifiedSync(DateTime(2000));
      await verifyLauncher(packed);
      expect(
        marker.lastModifiedSync(),
        DateTime(2000),
        reason: 'A warm start must reuse the extracted bundle.',
      );
      final cachedLibrary = Directory(
        p.join(marker.parent.path, 'lib'),
      ).listSync().whereType<File>().single..deleteSync();
      await verifyLauncher(packed);
      expect(
        cachedLibrary.existsSync(),
        isTrue,
        reason: 'An incomplete cache entry must be repaired.',
      );

      // Same-size corruption must be detected before the application runs.
      final damagedBytes = cachedLibrary.readAsBytesSync();
      final originalLength = damagedBytes.length;
      damagedBytes[0] = 0;
      cachedLibrary.writeAsBytesSync(damagedBytes);
      expect(cachedLibrary.lengthSync(), originalLength);
      await verifyLauncher(packed);
      expect(cachedLibrary.readAsBytesSync().first, isNot(0));

      cache.deleteSync(recursive: true);
      await Future.wait([verifyLauncher(packed), verifyLauncher(packed)]);
      expect(
        cache.listSync().whereType<Directory>().length,
        1,
        reason: 'Concurrent extraction publishes one complete cache entry.',
      );

      // A failed rebuild must leave the previous executable usable.
      write('project/tool.dart', 'this is not valid Dart');
      expect(
        () => DartSdk().runDartCompiler(
          script,
          pathToExe: script.pathToExe,
          workingDirectory: project,
          progress: Progress.capture(),
        ),
        throwsA(isA<RunException>()),
      );

      final installed = p.join(temporary.path, 'installed', 'bin', 'renamed');
      Directory(p.dirname(installed)).createSync(recursive: true);
      compiled.install(installed);
      Directory(project).deleteSync(recursive: true);
      await verifyLauncher(installed);
      await verifyLauncher(packed);
      final installedBundle = CompiledExecutable.bundlePath(installed);
      Directory(installedBundle).renameSync('$installedBundle.missing');
      final missing = await Process.run(installed, []);
      expect(missing.exitCode, 127);
      expect('${missing.stderr}', contains('Missing application bundle'));
      expect('${missing.stderr}', contains('.renamed.bundle'));
    },
    skip: Platform.isWindows ? 'Fixture requires a Unix C compiler.' : false,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
