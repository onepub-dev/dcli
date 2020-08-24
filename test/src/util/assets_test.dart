import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('Assets().toString', () async {
    var path = 'assets/templates/cli_args.dart';
    var content = Assets().loadString(path);

    expect(content, isNotNull);

    var actual = read(join(Script.current.pathToProjectRoot, 'lib', 'src', path))
        .toList()
        .join('\n');

    /// the join trims the last \n
    actual += '\n';

    expect(content, equals(actual));
  });

  test('Assets().list', () async {
    var path = 'assets/templates/';
    var templates = Assets().list('*.dart', root: path);

    var base = join(Script.current.pathToProjectRoot, 'lib', 'src', path);

    expect(
      templates,
      unorderedEquals(
        <String>[
          join(base, 'cli_args.dart'),
          join(base, 'hello_world.dart'),
          join(base, 'README.md'),
        ],
      ),
    );
  });
}
