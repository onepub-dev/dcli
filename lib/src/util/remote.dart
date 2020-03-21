import 'package:dshell/dshell.dart';
import 'package:meta/meta.dart';

///
/// Provides remote access methods for posix based systems.
///
class Remote {
  /// executes command on a remote host over an ssh tunnel
  /// [host] is the remote host to execute the command on.
  /// If [sudo] is true then the command will be run with sudo.
  /// If you specify [sudo] as true then you must also pass in the
  /// sudo [password] for your account on the remote host.
  /// [password] is the current user's password on the remote host.
  ///   The user's account on the remote host must be in the sudoers file.
  /// The [command] to execute on the remote host.
  /// The optional [progress] allows you to control how the output
  /// of the command is printed to the console. By default all output is supressed.
  ///
  /// ```dart
  ///  // run mkdir on the remote host using sudo
  ///  Remote.exec(
  ///     host: fqdn,
  ///     command: "mkdir -p /tmp/etc/openvpn",
  ///     sudo: true,
  ///     password: password,
  ///     progress: Progress.print());
  ///
  ///  // if you want to chain multiple commands and use ';' to separate each command.
  ///  // If the command (except for the first one) requires sudo access then you must
  ///  // pass the sudo password to each command via the 'sudo -S' switch which
  ///  // expects the password to be piped in:
  ///    echo $password | sudo -S <some command>
  ///  // The -p '' switch supresses the password prompt as this isn't required and it pollutes the output.
  ///  var command = "mkdir -p  /tmp/etc/openvpn; echo $password  | sudo -S -p '' cp -R /etc/openvpn/* /tmp/etc/openvpn; ls -l /tmp/etc/openvpn; echo $password | sudo -S -p ''  rm -rf /tmp/etc/openvpn ;  ls /tmp";
  ///
  ///   Remote.exec(
  ///     host: fqdn,
  ///     command: command,
  ///     sudo: true,
  ///     password: password,
  ///     progress: Progress.print());
  /// ```
  ///
  static void exec(
      {String host,
      String password,
      String command,
      bool sudo,
      Progress progress}) {
    assert(sudo == false || sudo == true && password != null);
    var cmdArgs = <String>[];
    cmdArgs.add('-T');
    cmdArgs.add('$host');

    if (sudo) {
      // -S accept echoed password
      // -k clear the sudo cached password so it expects a password
      // -p ''  blank out the password prompt give we are echoing the password in.
      cmdArgs.add('echo $password | sudo -Skp "" $command');
    } else {
      cmdArgs.add(command);
    }
    progress ??= Progress.devNull();

    startFromArgs('ssh', cmdArgs, progress: progress);
  }

  /// Run scp (secure copy) to copy files between remote hosts.
  ///
  /// [from] the from path
  /// [fromHost] the host the [from] path exists on. If [fromHost] isn't
  /// specified it is assumed that the from path is on the local machine
  /// [fromUser] the user to use to authenticate against the [fromHost].
  ///   You may only specify [fromUser] if [fromHost] is passed.
  ///
  /// [to] the to path. If [to] is not specified then the [from] path is used
  ///   on [to] path on the toHost.
  /// [toHost] the host the [to] path exists on. If [toHost] isn't
  /// specified it is assumed that the from path is on the local machine
  /// [toUser] the user to use to authenticate against the [toHost].
  ///   You may only specify [toUser] if [toHost] is passed.
  static void scp(
      {@required String from,
      String to,
      String fromHost,
      String toHost,
      String fromUser,
      String toUser}) {
    assert(from != null);
    // toUser is only valid if toHost is given
    assert(toUser != null && toHost != null || toUser == null);

    // fomrUser is only valid if fromHost is given
    assert(fromUser != null && fromHost != null || fromUser == null);

    // build fromArg user@host:/path
    var fromArg = '';
    if (fromHost != null) {
      if (fromUser != null) {
        fromArg += '$fromUser@';
      }
      fromArg += '$fromHost:$from';
    } else {
      fromArg = from;
    }

    to ??= from;

    // build toArg user@host:/path
    var toArg = '';
    if (toHost != null) {
      if (toUser != null) {
        toArg += '$toUser@';
      }
      toArg += '$toHost:$to';
    } else {
      toArg = to;
    }

    'scp  $fromArg $toArg'.run;
  }
}
