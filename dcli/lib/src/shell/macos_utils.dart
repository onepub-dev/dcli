import 'package:collection/collection.dart';

import '../../dcli.dart';

class MacOSUtils {
  /// Attempts to retrive the logged in user's home directory.
  /// If we can't find it we return /Users/${user}
  static String loggedInUsersHome(String user) {
    const keyHomeDirectory = 'NFSHomeDirectory';

    final nfsHome = 'dscl . -read /users/$user'
        .toList()
        .firstWhereOrNull((line) => line.startsWith(keyHomeDirectory));
    final parts = nfsHome == null ? <String>[] : nfsHome.split(':');

    final String pathToHome;
    if (parts.length == 2) {
      pathToHome = parts[1].trim();
    } else {
      pathToHome = '/Users/$user';
      verbose(() => 'NFSHomeDirecctory not found for $user');
    }

    return pathToHome;
  }
}
