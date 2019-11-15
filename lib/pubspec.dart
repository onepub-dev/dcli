import 'yaml.dart';

class PubSpec {
  static PubSpec _self = PubSpec._internal();
  Yaml yaml;

  factory PubSpec() {
    return _self;
  }

  String get name => yaml.getValue("name");
  String get version => yaml.getValue("version");

  /// You must call load before using any of the methods on this class.
  void load() async {
    if (yaml == null) {
      yaml = await Yaml("pubspec.yaml");
      await yaml.load();
    }

    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String version = packageInfo.version;
  }

  PubSpec._internal();
}
