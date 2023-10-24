import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:settings_yaml/settings_yaml.dart';

import '../commands/config.dart';
import '../commands/install.dart';

class AppSettings {
  AppSettings() {
    /// store the settings in ~/.full/settings.yaml
    /// NOTE: rename .full to match your app name.
    final pathToAppSettingsDir = join(
      HOME,
      '.full',
    );

    final pathToAppSettings = join(pathToAppSettingsDir, filename);

    _createSettingsDir(pathToAppSettingsDir);

    /// read current settings.
    settings = SettingsYaml.load(pathToSettings: pathToAppSettings);

    /// read each of the current config options from the settings file
    /// providing a default incase it hasn't been initialised.
    httpPort = settings.asInt(ConfigCommand.httpPortOption, defaultValue: 8025);
    smtpPort = settings.asInt(ConfigCommand.smtpPortOption, defaultValue: 1025);
    pathToMailHogApp = settings.asString(pathToMailHogAppOption,
        defaultValue: InstallCommand.defaultMailHogAppPath);
  }

  static const filename = 'settings.yaml';

  /// key for the settings file
  static const pathToMailHogAppOption = 'path-to-app';

  /// Create the settings directory.
  void _createSettingsDir(String pathToAppSettingsDir) {
    if (!exists(pathToAppSettingsDir)) {
      createDir(pathToAppSettingsDir);
    }
  }

  /// Does the heavy lifting of reading/writing settings.
  late final SettingsYaml settings;
  late int _httpPort;
  late int _smtpPort;
  late String _pathToMailHogApp;

  // httpPort for mailhog to listen on.
  set httpPort(int httpPort) {
    _httpPort = httpPort;
    settings[ConfigCommand.httpPortOption] = httpPort;
  }

  int get httpPort => _httpPort;

  // smtpPort fo rmail hog to listen on
  set smtpPort(int smtpport) {
    _smtpPort = smtpport;
    settings[ConfigCommand.smtpPortOption] = smtpport;
  }

  int get smtpPort => _smtpPort;

  // path to where we will install the mailhog app.
  set pathToMailHogApp(String pathToMailHogApp) {
    settings[AppSettings.pathToMailHogAppOption] = pathToMailHogApp;
    _pathToMailHogApp = pathToMailHogApp;
  }

  String get pathToMailHogApp => _pathToMailHogApp;

  /// Save the settings file.
  Future<void> save() async {
    await settings.save();
  }
}
