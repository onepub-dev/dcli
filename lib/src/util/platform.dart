import 'dart:io';

/// Extensions for the Platform class
extension PlatformEx on Platform {
  /// Returns the OS specific End Of Line (eol) character.
  /// On Windows this is '\r\n' on all other platforms
  /// it is '\n'.
   String get eol => Platform.isWindows ? '\r\n' : '\n';
}
