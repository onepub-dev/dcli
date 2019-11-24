import 'package:dshell/dshell.dart';
import 'package:dshell/script/yaml.dart';
import 'package:test/test.dart' as t;

void main() {
  Settings().debug_on = true;

  t.test("Project Name", () {
    print("$pwd");
    Yaml yaml = Yaml("pubspec.yaml");
    yaml.load();
    String projectName = yaml.getValue("name");

    t.expect(projectName, t.equals("dshell"));
  });
}
