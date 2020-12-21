import '../../dcli.dart';

import 'dcli_function.dart';

///
/// Does an insitu replacement on the file located at [path].
///
/// [replace] searches the file at [path] for any occurances
/// of [existing] and replaces them with [replacement].
///
/// By default we only replace the first occurance of [existing] on each line.
/// To replace every (non-overlapping) occurance of [existing] on a line then set [all] to true;
///
/// The [replace] method returns the no. of lines modified.
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
int replace(String path, String existing, String replacement,
        {bool all = false}) =>
    _Replace().replace(path, existing, replacement, all: all);

class _Replace extends DCliFunction {
  int replace(String path, String existing, String replacement,
      {bool all = false}) {
    var changes = 0;
    final tmp = '$path.tmp';
    if (exists(tmp)) {
      delete(tmp);
    }
    touch(tmp, create: true);
    read(path).forEach((line) {
      String newline;
      if (all) {
        newline = line.replaceAll(existing, replacement);
      } else {
        newline = line.replaceFirst(existing, replacement);
      }
      if (newline != line) {
        changes++;
      }

      tmp.append(newline);
    });
    if (changes != 0) {
      move(path, '$path.bak');
      move(tmp, path);
      delete('$path.bak');
    } else {
      delete(tmp);
    }
    return changes;
  }
}
