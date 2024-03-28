@Timeout(Duration(seconds: 600))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/dart_sdk.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test(
    'Detect Dart SDK',
    () {
      print('Dart pathToDartExe: ${DartSdk().pathToDartExe}');
      print('Dart pathToDartToNativeExe: ${DartSdk().pathToDartToNativeExe}');
      print('Dart pathToPubExe: ${DartSdk().pathToPubExe}');
      print('Dart Version: ${DartSdk().version}');
      print('Dart Major: ${DartSdk().versionMajor}');
      print('Dart Minor: ${DartSdk().versionMinor}');

      which('dart').paths.forEach((line) => print('which: $line'));
    },
    skip: false,
  );

  test('Install Dart Sdk', () async {
    await withTempDir((tempPath) async {
      final defaultPath = join(tempPath, 'dart-sdk');
      final installPath = await DartSdk().installFromArchive(defaultPath);
      setPathToDartSdk(installPath);
      print('installed To $installPath');
      expect(exists(join(defaultPath, 'bin', DartSdk.dartExeName)), isTrue);
      expect(
        DartSdk().pathToDartExe != null && exists(DartSdk().pathToDartExe!),
        equals(true),
      );
    });
  }, skip: false, tags: ['privileged']);

  test('Parse sdk version', () {
    final output = '${DartSdk().pathToDartExe} --version'.firstLine;

    expect(output, contains('Dart'));

    final version = DartSdk().version;

    expect(output, contains(version));

    expect(version, isNot(equals(null)));
  });

  test('Run dart pub', () {
    final progress = DartSdk()
        .runPub(args: ['publish', '--help'], progress: Progress.capture());
    final line = progress.lines;
    expect(line.isNotEmpty, equals(true));
    expect(line[0], equals('Publish the current package to pub.dev.'));
  });

  test('Run dart pub', () {
    final progress = DartSdk()
        .runPub(args: ['publish', '--help'], progress: Progress.devNull());
    print(progress.runtimeType);
    // final line = progress.lines;
    // expect(line.isNotEmpty, equals(true));
    // expect(line[0]
    // , equals('Publish the current package to pub.dev.'));
  });

  test('Run dart script', () {
    final projectRoot = DartProject.fromPath('.').pathToProjectRoot;
    final hellow = join(
      projectRoot,
      '..',
      'dcli_unit_tester',
      'test',
      'test_script',
      'general',
      'bin',
      'hello_world.dart',
    );
    DartSdk().run(args: [hellow]);
    print('done 1');
  });

  test('isPubGetRequried', () async {
    await withTempDir((tmpDir) async {
      final pubspec = join(tmpDir, 'pubspec.yaml');
      final lock = join(tmpDir, 'pubspec.lock');
      final config = join(tmpDir, '.dart_tool', 'package_config.json');

      createDir(dirname(config), recursive: true);

      touch(pubspec, create: true);

      /// make certain the lock and config arn't created in the same millsecond.
      sleep(10, interval: Interval.milliseconds);
      touch(lock, create: true);
      touch(config, create: true);

      /// all good
      expect(DartSdk().isPubGetRequired(tmpDir), false);

      /// missing lock
      delete(lock);
      expect(DartSdk().isPubGetRequired(tmpDir), true);
      touch(lock, create: true);

      // missing package_config.json
      delete(config);
      expect(DartSdk().isPubGetRequired(tmpDir), true);

      // missing .dart_tool
      deleteDir(dirname(config));
      expect(DartSdk().isPubGetRequired(tmpDir), true);

      createDir(dirname(config), recursive: true);
      touch(lock, create: true);
      touch(config, create: true);

      // old lock
      touch(lock, create: true);
      sleep(1000, interval: Interval.milliseconds);
      touch(pubspec);
      expect(DartSdk().isPubGetRequired(tmpDir), true);

      // old package_config.json
      touch(config, create: true);
      // access times are only to nearest second so force a difference.
      sleep(1000, interval: Interval.milliseconds);
      touch(pubspec);
      touch(lock, create: true);

      expect(DartSdk().isPubGetRequired(tmpDir), true);
    });
  });
}
