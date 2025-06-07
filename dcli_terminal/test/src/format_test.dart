import 'dart:math';

import 'package:dcli_terminal/src/format.dart';
import 'package:test/test.dart';

void main() {
  group('bytesAsReadable', () {
    test('bytes < 1 KB use “B” and pad left', () {
      expect(Format().bytesAsReadable(500), equals('  500B'));
      expect(Format().bytesAsReadable(1023), equals(' 1023B'));
    });

    test('=10000', () {
      expect(Format().bytesAsReadable(10000), equals('9.766K'));
    });

    test('1 KB exactly formats as 1.000K', () {
      expect(Format().bytesAsReadable(1024), equals('1.000K'));
    });

    test('1500 bytes ≈ 1.465K', () {
      expect(Format().bytesAsReadable(1500), equals('1.465K'));
    });

    test('1 MiB formats as 1.000M', () {
      expect(Format().bytesAsReadable(1 * 1024 * 1024), equals('1.000M'));
    });

    test('5 MiB formats as 5.000M', () {
      expect(Format().bytesAsReadable(5 * 1024 * 1024), equals('5.000M'));
    });

    test('10 GiB formats as 10.00G', () {
      expect(
          Format().bytesAsReadable(10 * 1024 * 1024 * 1024), equals('10.00G'));
    });

    test('Large value (~308.3 GiB) formats correctly', () {
      const bytes = 331022187392; // ≈ 308.3 GiB
      expect(Format().bytesAsReadable(bytes), equals('308.3G'));
    });
  });

  group('bytesAsReadable threshold boundaries', () {
    // B → K boundary
    test('just below 1 KB (1023 B)', () {
      expect(Format().bytesAsReadable(1023), equals(' 1023B'));
    });
    test('1 KB exactly (1024 B)', () {
      expect(Format().bytesAsReadable(1024), equals('1.000K'));
    });

    // K → M boundary
    test('just below 1 MB (1 MiB - 1 B)', () {
      const bytes = 1024 * 1024 - 1;
      expect(Format().bytesAsReadable(bytes), equals(' 1024K'));
    });
    test('1 MB exactly (1 MiB)', () {
      const bytes = 1024 * 1024;
      expect(Format().bytesAsReadable(bytes), equals('1.000M'));
    });

    // M → G boundary
    test('just below 1 GB (1 GiB - 1 B)', () {
      const bytes = 1024 * 1024 * 1024 - 1;
      expect(Format().bytesAsReadable(bytes), equals(' 1024M'));
    });
    test('1 GB exactly (1 GiB)', () {
      const bytes = 1024 * 1024 * 1024;
      expect(Format().bytesAsReadable(bytes), equals('1.000G'));
    });

    // G → T boundary
    test('just below 1 TB (1 TiB - 1 B)', () {
      const bytes = 1024 * 1024 * 1024 * 1024 - 1;
      expect(Format().bytesAsReadable(bytes), equals(' 1024G'));
    });
    test('1 TB exactly (1 TiB)', () {
      const bytes = 1024 * 1024 * 1024 * 1024;
      expect(Format().bytesAsReadable(bytes), equals('1.000T'));
    });
  });
  group('TB & above', () {
    test('1 TiB exactly', () {
      expect(Format().bytesAsReadable(1024 * 1024 * 1024 * 1024),
          equals('1.000T'));
    });
    test('just below T threshold (1 TiB - 1)', () {
      const b = 1024 * 1024 * 1024 * 1024 - 1;
      expect(Format().bytesAsReadable(b), equals(' 1024G')); // still GB
    });
    test('≥1 P triggers scientific', () {
      // 1 Peta byte = 1024^5
      final b = pow(1024, 5).toInt();
      expect(Format().bytesAsReadable(b), equals(b.toStringAsExponential(0)));
    });
    test('very large but within 64-bit', () {
      const b = 9223372036854775807; // 2^63-1
      expect(Format().bytesAsReadable(b), equals(b.toStringAsExponential(0)));
    });
  });

  group('bytesAsReadable pad=false (no padding)', () {
    test('500 B', () {
      expect(Format().bytesAsReadable(500, pad: false), equals('500B'));
    });

    test('1023 B', () {
      expect(Format().bytesAsReadable(1023, pad: false), equals('1023B'));
    });

    test('1 KB exactly', () {
      expect(Format().bytesAsReadable(1024, pad: false), equals('1.000K'));
    });

    test('1500 bytes ≈ 1.465K', () {
      expect(Format().bytesAsReadable(1500, pad: false), equals('1.465K'));
    });

    test('just below 1 MB', () {
      const bytes = 1024 * 1024 - 1;
      expect(Format().bytesAsReadable(bytes, pad: false), equals('1024K'));
    });

    test('1 MiB exactly', () {
      expect(
          Format().bytesAsReadable(1024 * 1024, pad: false), equals('1.000M'));
    });

    test('10 GiB', () {
      expect(Format().bytesAsReadable(10 * 1024 * 1024 * 1024, pad: false),
          equals('10.00G'));
    });

    test('1 TiB exactly', () {
      expect(Format().bytesAsReadable(1024 * 1024 * 1024 * 1024, pad: false),
          equals('1.000T'));
    });

    test('≥1 PiB triggers scientific', () {
      final bytes = pow(1024, 5).toInt(); // 1 PiB
      expect(Format().bytesAsReadable(bytes, pad: false),
          equals(bytes.toStringAsExponential(0)));
    });
  });
}
