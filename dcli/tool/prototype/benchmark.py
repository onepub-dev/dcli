#!/usr/bin/env python3
"""Linux benchmark for the single-file prototype; requires Dart, cc and GNU time."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--sizes', nargs='+', type=int, default=[0, 16, 64],
                    help='Additional incompressible payload sizes in MiB.')
parser.add_argument('--output-dir', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
output = args.output_dir or Path(tempfile.mkdtemp(prefix='dcli-pack-benchmark-'))
output.mkdir(parents=True, exist_ok=True)
output = output.resolve()
print(f'Benchmark artifacts: {output}', flush=True)
base = output / 'fixture'
(base / 'bin').mkdir(parents=True)
(base / 'lib').mkdir()
(base / 'answer.c').write_text('int answer(void) { return 42; }\n')
subprocess.run(['cc', '-shared', '-fPIC', str(base / 'answer.c'),
                '-o', str(base / 'lib/libanswer.so')], check=True)
(base / 'tool.dart').write_text('''
import 'dart:ffi';
import 'dart:io';
void main() {
  final path = File(Platform.resolvedExecutable).parent.uri
      .resolve('../lib/libanswer.so').toFilePath();
  final answer = DynamicLibrary.open(path)
      .lookupFunction<Int32 Function(), int Function()>('answer');
  print(answer());
}
''')
subprocess.run(['dart', 'compile', 'exe', str(base / 'tool.dart'),
                f'--output={base / "bin/tool"}'], check=True, cwd=base)


def timed(command, name, env=None):
    metrics = output / f'{name}.time'
    result = subprocess.run(
        ['/usr/bin/time', '-f', '%M %e', '-o', str(metrics), *command],
        cwd=root, env=env, text=True, capture_output=True)
    (output / f'{name}.stdout').write_text(result.stdout)
    (output / f'{name}.stderr').write_text(result.stderr)
    if result.returncode:
        raise RuntimeError(f'{name} failed: {result.stdout}\n{result.stderr}')
    rss, elapsed = metrics.read_text().strip().split()
    return {'peakRssKiB': int(rss), 'seconds': float(elapsed)}, result.stdout


results = []
for size in args.sizes:
    if size < 0:
        raise ValueError('Payload sizes must be nonnegative')
    case = output / f'{size}MiB'
    bundle = case / 'bundle'
    (bundle / 'bin').mkdir(parents=True)
    (bundle / 'lib').mkdir()
    shutil.copy2(base / 'bin/tool', bundle / 'bin/tool')
    shutil.copy2(base / 'lib/libanswer.so', bundle / 'lib/libanswer.so')
    if size:
        with (bundle / 'payload.bin').open('wb') as payload:
            for _ in range(size):
                payload.write(os.urandom(1024 * 1024))
    build, _ = timed(['dart', 'run', 'tool/prototype/single_file.dart',
                     '--build-dir', str(case / 'generated'), str(bundle),
                     str(case / 'tool')], f'{size}-build')
    env = {**os.environ, 'DCLI_BUNDLE_CACHE': str(case / 'cache'),
           'DCLI_BUNDLE_VERBOSE': '1'}
    cold, stdout = timed([str(case / 'tool')], f'{size}-cold', env)
    assert stdout.strip() == '42', stdout
    warm, stdout = timed([str(case / 'tool')], f'{size}-warm', env)
    assert stdout.strip() == '42', stdout
    data = json.loads((case / 'generated/metrics.json').read_text())
    row = {'payloadMiB': size, **data, 'build': build, 'cold': cold, 'warm': warm}
    results.append(row)
    print(json.dumps(row), flush=True)
    (output / 'results.json').write_text(json.dumps(results, indent=2))
