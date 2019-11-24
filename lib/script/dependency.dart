class Dependency {
  final String name;

  final String version;

  const Dependency(this.name, this.version);

  static Dependency fromLine(String line) {
    Dependency dep;

    List<String> parts = line.split(' ');
    if (parts.length == 3) {
      dep = Dependency(parts[1], parts[2]);
    }
    return dep;
  }
}
