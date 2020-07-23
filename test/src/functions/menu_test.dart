import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

void main() {
  test('menu - defaultValue', () {
    Settings().setVerbose(enabled: true);
    var options = ['public', 'private'];

    var result = menu(
        prompt: 'How old are you', defaultValue: 'public', options: options);
    print('result: $result');

    var numoptions = [3.14, 8.9];
    var result1 =
        menu(prompt: 'How old are you', defaultValue: 8.9, options: numoptions);
    print('result: $result1');

    try {
      menu(prompt: 'How old are you', defaultValue: 9, options: numoptions);
    } on ArgumentError catch (e) {
      print('Expected Argument error ${e.toString()}');
    }
    print('result: $result1');
  }, skip: true);
}
