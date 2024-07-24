import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

class TestDirectoryTree {
  /// Builds the test directory tree and populates it.
  TestDirectoryTree(this.root) {
    _build();
  }

  String root;

  late String top;
  late String thidden;
  late String middle;
  late String bottom;
  late String hidden;

  late final String topFredJpg;
  late final String topFredPng;
  late final String thiddenFredTxt;
  late final String topOneTxt;
  late final String topTwoTxt;
  late final String topOneJpg;
  late final String topDotTwoTxt;
  late final String middleThreeTxt;
  late final String middleFourTxt;
  late final String middleTwoJpg;
  late final String middleDotFourTxt;
  late final String bottomFiveTxt;
  late final String bottomSixTxt;
  late final String bottomThreeJpg;
  late final String hiddenSevenTxt;
  late final String hiddenDotSevenTxt;

  void _build() {
    if (!exists(HOME)) {
      createDir(HOME, recursive: true);
    }

    top = join(root, 'top');
    thidden = join(top, '.hidden');
    middle = join(top, 'middle');
    bottom = join(middle, 'bottom');
    hidden = join(middle, '.hidden');

    topFredJpg = join(top, 'fred.jpg');
    topFredPng = join(top, 'fred.png');
    thiddenFredTxt = join(thidden, 'fred.txt');
    topOneTxt = join(top, 'one.txt');
    topTwoTxt = join(top, 'two.txt');
    topOneJpg = join(top, 'one.jpg');
    topDotTwoTxt = join(top, '.two.txt');
    middleThreeTxt = join(middle, 'three.txt');
    middleFourTxt = join(middle, 'four.txt');
    middleTwoJpg = join(middle, 'two.jpg');
    middleDotFourTxt = join(middle, '.four.txt');
    bottomFiveTxt = join(bottom, 'five.txt');
    bottomSixTxt = join(bottom, 'six.txt');
    bottomThreeJpg = join(bottom, 'three.jpg');
    hiddenSevenTxt = join(hidden, 'seven.txt');
    hiddenDotSevenTxt = join(hidden, '.seven.txt');

    populateFileSystem(top, thidden, middle, bottom, hidden);
  }

  static void populateFileSystem(
    String top,
    String thidden,
    String middle,
    String bottom,
    String hidden,
  ) {
    // Create some the test dirs.
    if (!exists(thidden)) {
      createDir(thidden, recursive: true);
    }

    // Create some the test dirs.
    if (!exists(bottom)) {
      createDir(bottom, recursive: true);
    }

    // Create some the test dirs.
    if (!exists(hidden)) {
      createDir(hidden, recursive: true);
    }

    // Create test files

    touch(join(top, 'fred.jpg'), create: true);
    touch(join(top, 'fred.png'), create: true);
    touch(join(thidden, 'fred.txt'), create: true);

    touch(join(top, 'one.txt'), create: true);
    touch(join(top, 'two.txt'), create: true);
    touch(join(top, 'one.jpg'), create: true);
    touch(join(top, '.two.txt'), create: true);

    touch(join(middle, 'three.txt'), create: true);
    touch(join(middle, 'four.txt'), create: true);
    touch(join(middle, 'two.jpg'), create: true);
    touch(join(middle, '.four.txt'), create: true);

    touch(join(bottom, 'five.txt'), create: true);
    touch(join(bottom, 'six.txt'), create: true);
    touch(join(bottom, 'three.jpg'), create: true);

    touch(join(hidden, 'seven.txt'), create: true);
    touch(join(hidden, '.seven.txt'), create: true);
  }
}
