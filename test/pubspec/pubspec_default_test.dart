@t.Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:dshell/pubspec/global_dependancies.dart';
import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/project_cache.dart';
import 'package:dshell/script/script.dart';
import 'package:dshell/script/virtual_project.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart' as t;

import '../test_settings.dart';

String parent = p.join(TEST_ROOT, "local");
String path = p.join(parent, "test.dart");

void main() {
  String main = """
void main()
{
  print ("hello world");
}

""";

  String basic = """name: test
version: 1.0.0
dependencies:
  collection: ^1.14.12
  file_utils: ^0.1.3
""";

  String overrides = """name: test
version: 1.0.0
dependencies:
  dshell: ^2.0.0
  args: ^2.0.1
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^2.0.2
""";

  t.test("No PubSpec - No Dependancies", () {
    runTest(null, main, GlobalDependancies.defaultDependencies);
  }, skip: false);

  String annotationNoOverrides = """
    /* @pubspec.yaml
${basic}
*/
  """;

  t.test("Annotation - No Overrides", () {
    List<Dependency> dependencies = GlobalDependancies.defaultDependencies;
    dependencies.add(Dependency("collection", "^1.14.12"));
    dependencies.add(Dependency("file_utils", "^0.1.3"));
    runTest(annotationNoOverrides, main, dependencies);
  }, skip: false);

  String annotationWithOverrides = """
    /* @pubspec.yaml
$overrides
*/
  """;

  t.test("Annotaion With Overrides", () {
    List<Dependency> dependencies = List();
    dependencies.add(Dependency("dshell", "^2.0.0"));
    dependencies.add(Dependency("args", "^2.0.1"));
    dependencies.add(Dependency("path", "^2.0.2"));
    dependencies.add(Dependency("collection", "^1.14.12"));
    dependencies.add(Dependency("file_utils", "^0.1.3"));
    runTest(annotationWithOverrides, main, dependencies);
  }, skip: false);

  t.test("File - basic", () {
    PubSpec file = PubSpecImpl.fromString(basic);
    file.writeToFile(path);

    List<Dependency> dependencies = GlobalDependancies.defaultDependencies;
    dependencies.add(Dependency("collection", "^1.14.12"));
    dependencies.add(Dependency("file_utils", "^0.1.3"));
    runTest(null, main, dependencies);
  }, skip: false);

  t.test("File - override", () {
    PubSpec file = PubSpecImpl.fromString(overrides);
    file.writeToFile(path);

    List<Dependency> dependencies = List();
    dependencies.add(Dependency("dshell", "^2.0.0"));
    dependencies.add(Dependency("args", "^2.0.1"));
    dependencies.add(Dependency("path", "^2.0.2"));
    dependencies.add(Dependency("collection", "^1.14.12"));
    dependencies.add(Dependency("file_utils", "^0.1.3"));
    runTest(null, main, dependencies);
  }, skip: false);
}

void runTest(String annotation, String main, List<Dependency> expected) {
  ProjectCache().initCache();

  createDir(parent, recursive: true);
  path.truncate();
  if (annotation != null) {
    path.append(annotation);
  }
  path.append(main);

  Script script = Script.fromFile(path);
  if (exists(VirtualProject(ProjectCache().path, script).path)) {
    deleteDir(VirtualProject(ProjectCache().path, script).path,
        recursive: true);
  }
  VirtualProject project =
      ProjectCache().createProject(script, skipPubGet: true);

  PubSpec pubspec = project.pubSpec();
  t.expect(pubspec.dependencies, t.equals(expected));
}
