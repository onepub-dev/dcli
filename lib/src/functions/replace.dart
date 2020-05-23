import '../../dshell.dart';

import 'dshell_function.dart';

///
/// Does an insitu replacement on the file located at [path].
///
/// [replace] searches the file at [path] for any occurances
/// of [existing] and replaces them with [replacement].
///
/// During the process a tempory file called [path].tmp is created
/// in the directory of [path].
/// The modified file is written to [path].tmp.
/// Once the replacement completes successfully the file at [path]
/// is renamed to [path].bak, [path].tmp is renamed to [path] and then
/// [path].bak is deleted.
///
/// The above process essentially makes replace atomic so it should
/// be impossible to loose your file. If replace does crash you may
/// have to delete [path].tmp or [path].bak but this is highly unlikely.
///
/// EXPERIMENTAL - this api may change. It is fairly likely to stay
/// just that existing may change to support [Pattern]
void replace(String path, String existing, String replacement) =>
    _Replace().replace(path, existing, replacement);

class _Replace extends DShellFunction {
  void replace(String path, String existing, String replacement) {
    var tmp = '$path.tmp';
    if (exists(tmp)) {
      delete(tmp);
    }
    read(path).forEach((line) {
      line = line.replaceFirst(existing, replacement);
      tmp.append(line);
    });
    move(path, '$path.bak');
    move(tmp, path);
    delete('$path.bak');
  }
}
