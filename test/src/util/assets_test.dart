import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('Assets().toString', () async {
    final path = join('assets', 'templates', 'basic.dart');
    final content = Assets().loadString(path);

    final lineDelimiter = Platform.isWindows ? '\r\n' : '\n';

    expect(content, isNotNull);

    var actual =
        read(join(DartProject.self.pathToProjectRoot, 'lib', 'src', path))
            .toList()
            .join(lineDelimiter);

    /// the join trims the last \n
    actual += lineDelimiter;

    expect(content, equals(actual));
  });

  test('Assets().list', () async {
    final path = join('assets', 'templates');
    final templates = Assets().list('*', root: path);

    final base = join(DartProject.self.pathToProjectRoot, 'lib', 'src', path);

    expect(
      templates,
      unorderedEquals(
        <String>[
          join(base, 'basic.dart'),
          join(base, 'hello_world.dart'),
          join(base, 'README.md'),
          join(base, 'analysis_options.yaml'),
          join(base, 'pubspec.yaml.template'),
          join(base, 'cmd_args.dart')
        ],
      ),
    );
  });
}
