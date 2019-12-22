import 'package:equatable/equatable.dart';

class Dependency extends Equatable {
  final String name;

  final String version;

  const Dependency(this.name, this.version);

  static Dependency fromLine(String line) {
    Dependency dep;

    var parts = line.split(' ');
    if (parts.length == 3) {
      dep = Dependency(parts[1], parts[2]);
    }
    return dep;
  }

/*  Dependency.fromYaml(YamlNode node)
      : name = extractName(node),
        version = extractVersion(node);
*/
/*  static String extractVersion(YamlNode node) {
    print(node);
  }

  static String extractName(YamlNode node) {
    print(node);
  }
*/
  @override
  List<Object> get props => [name, version];

  @override
  String toString() {
    return '$name : $version';
  }
}
