/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('env ...', () async {
    expect(Env().exists('PATH') == true, isTrue);
    expect(Env().exists('FREDWASHERE') == true, isFalse);
    env['AAAA'] = null;
    expect(Env().exists('AAAA') == true, isFalse);
    env['AAAA'] = '';
    expect(Env().exists('AAAA') == true, isTrue);
  });

  test('env nested withEnvironment', () async {
    const envVar = 'AAABBBCCC';
    const envVar2 = 'AAABBBCCCDDD';
    const envVar3 = 'AAABBBCCCDDDEEE';
    expect(env.exists(envVar), false);
    await withEnvironment(environment: {envVar: 'one', envVar2: 'two'},
        () async {
      expect(env.exists(envVar), true);
      expect(env[envVar], 'one');

      await withEnvironment(environment: {envVar: 'one-one'}, () async {
        expect(env.exists(envVar), true);
        expect(env[envVar], 'one-one');

        expect(env[envVar2], 'two');

        await withEnvironment(
            environment: {envVar3: 'three', envVar2: 'two-two'}, () async {
          expect(env.exists(envVar), true);
          expect(env[envVar], 'one-one');

          expect(env[envVar2], 'two-two');
          expect(env[envVar3], 'three');
        });
      });
    });
  });
}
