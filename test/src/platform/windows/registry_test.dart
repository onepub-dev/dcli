import 'package:dcli/windows.dart';
import 'package:test/test.dart';
import 'package:win32/win32.dart';

void main() {
  test('windows mixin ...', () async {
    setRegistryString(HKEY_CURRENT_USER, 'Environment', 'PATH_TEST', 'HI');

    final paths =
        getRegistryString(HKEY_CURRENT_USER, 'Environment', 'PATH_TEST');
    expect(paths, equals('HI'));
    //appendToPath('bb');
  });

  // test('set/get lsit', (){
  //   setRegistryList(HKEY_CURRENT_USER, subKey, valueName, value)
  // })

  test('set/get string', () {
    setRegistryString(
        HKEY_CURRENT_USER, 'Environment', 'TEST_KEY', 'Hellow World');
    expect(getRegistryString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY'),
        equals('Hellow World'));
  });

  test('set/get expanding string', () {
    setRegistryString(
        HKEY_CURRENT_USER, 'Environment', 'TEST_KEY', 'Hellow World');
    setRegistryExpandString(
        HKEY_CURRENT_USER, 'Environment', 'TEST_KEY2', '%USERPROFILE%2');

    final testKey2 =
        getRegistryExpandString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY2');
    expect(testKey2, startsWith('C:'));
    expect(testKey2, endsWith('2'));

    expect(
        getRegistryExpandString(HKEY_CURRENT_USER, 'Environment', 'TEST_KEY2',
            expand: false),
        equals('%USERPROFILE%2'));
  });

  test('append to path', () {
    final original = getRegistryExpandString(
        HKEY_CURRENT_USER, 'Environment', 'Path',
        expand: false);
    appendToPath(r'\TestDir');
    final updated = getRegistryExpandString(
        HKEY_CURRENT_USER, 'Environment', 'Path',
        expand: false);
    expect(updated, equals('$original;\\TestDir'));
  });
}
