import 'package:dshell/dshell.dart';
import 'package:dshell/yaml.dart';
import 'package:test/test.dart' as t;

void main() async {
  Settings().debug_on = true;

  t.test("Project Name", () async {
    print("$pwd");
    Yaml yaml = Yaml("pubspec.yaml");
    String projectName = yaml.getValue("name");

    t.expect(projectName, t.equals("dshell"));
  });
}
