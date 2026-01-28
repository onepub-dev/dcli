/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('env ...', () {
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
