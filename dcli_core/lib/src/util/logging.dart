///
/// If Settings.isVerbose is true then
/// this method will call [callback] to
/// get a String which will be logged to the
/// console or the log file set via the verbose command line
/// option.
///
/// This method is more efficient than calling Settings.verbose
/// as it will only build the string if verbose is enabled.
///
/// ```dart
/// verbose(() => 'Log the users name $user');
///
void verbose(String Function() callback) {
  // TODO what do we do with verbose settings on a non-console platform.
  // if (Settings().isVerbose) {
  //   final string = callback();
  //   if (VerboseFlag().hasOption) {
  //     VerboseFlag().option.append(string);
  //   } else {
  //     print(string);
  //   }
  // }
}
