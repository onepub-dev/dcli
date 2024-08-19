/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('env ...', () async {
    expect(Env().exists('PATH'), isTrue);
    expect(Env().exists('FREDWASHERE'), isFalse);
    env['AAAA'] = null;
    expect(Env().exists('AAAA'), isFalse);
    env['AAAA'] = '';
    expect(Env().exists('AAAA'), isTrue);
  });

  test('env nested withEnvironment', () async {
    const envVar = 'AAABBBCCC';
    const envVar2 = 'AAABBBCCCDDD';
    const envVar3 = 'AAABBBCCCDDDEEE';
    expect(env.exists(envVar), false);
    await withEnvironmentAsync(environment: {envVar: 'one', envVar2: 'two'},
        () async {
      expect(env.exists(envVar), true);
      expect(env[envVar], 'one');

      await withEnvironmentAsync(environment: {envVar: 'one-one'}, () async {
        expect(env.exists(envVar), true);
        expect(env[envVar], 'one-one');

        expect(env[envVar2], 'two');

        await withEnvironmentAsync(
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
