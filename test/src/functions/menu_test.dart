@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('menu - defaultValue', () {
    Settings().setVerbose(enabled: true);

    var options = ['public', 'private'];

    var result =
        menu(prompt: 'How old are you', defaultOption: null, options: options);
    print('result: $result');

    result = menu(
        prompt: 'How old are you', defaultOption: 'public', options: options);
    print('result: $result');

    var numoptions = [3.14, 8.9];
    var result1 = menu(
        prompt: 'How old are you', defaultOption: 8.9, options: numoptions);
    print('result: $result1');

    try {
      menu(prompt: 'How old are you', defaultOption: 9, options: numoptions);
    } on ArgumentError catch (e) {
      print('Expected Argument error ${e.toString()}');
    }
    print('result: $result1');
  }, skip: true);
}
