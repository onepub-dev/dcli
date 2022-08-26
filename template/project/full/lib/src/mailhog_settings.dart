import 'package:dcli/dcli.dart';
import 'package:settings_yaml/settings_yaml.dart';

import 'commands/config.dart';
import 'commands/install.dart';

class MailHogSettings {
  MailHogSettings() {
    final pathToMailHogSettingsDir = join(
      HOME,
      '.dmailhog',
    );

    final pathToMailHogSettings = join(pathToMailHogSettingsDir, filename);

    _createDir(pathToMailHogSettingsDir);

    settings = SettingsYaml.load(pathToSettings: pathToMailHogSettings);

    httpPort = settings.asInt(ConfigCommand.httpPortOption, defaultValue: 8025);
    smtpPort = settings.asInt(ConfigCommand.smtpPortOption, defaultValue: 1025);

    pathToApp = settings.asString(pathToAppOption,
        defaultValue: InstallCommand.defaultMailHogAppPath);
  }

  static const filename = 'settings.yaml';
  static const pathToAppOption = 'path-to-app';

  void _createDir(String pathToMailHogSettingsDir) {
    if (!exists(pathToMailHogSettingsDir)) {
      createDir(pathToMailHogSettingsDir);
    }
  }

  late final SettingsYaml settings;
  late int _httpPort;
  late int _smtpPort;
  late String _pathToApp;

  // httpPort
  set httpPort(int httpPort) {
    _httpPort = httpPort;
    settings[ConfigCommand.httpPortOption] = httpPort;
  }

  int get httpPort => _httpPort;

  // smtpPort
  set smtpPort(int smtpport) {
    _smtpPort = smtpport;
    settings[ConfigCommand.smtpPortOption] = smtpport;
  }

  int get smtpPort => _smtpPort;

  // pathToApp
  set pathToApp(String pathToMailHogApp) {
    settings[MailHogSettings.pathToAppOption] = pathToMailHogApp;
    _pathToApp = pathToMailHogApp;
  }

  String get pathToApp => _pathToApp;

  void save() {
    settings.save();
  }
}
