import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('format humanReadable', () async {
    expect(Format.bytesAsReadable(1), '    1B');
    expect(Format.bytesAsReadable(11), '   11B');
    expect(Format.bytesAsReadable(121), '  121B');

    expect(Format.bytesAsReadable(1000), '1.000K');
    expect(Format.bytesAsReadable(1234), '1.234K');
    expect(Format.bytesAsReadable(11000), '11.00K');
    expect(Format.bytesAsReadable(121000), '121.0K');

    expect(Format.bytesAsReadable(1000000), '1.000M');
    expect(Format.bytesAsReadable(11000000), '11.00M');
    expect(Format.bytesAsReadable(121000000), '121.0M');

    expect(Format.bytesAsReadable(1000000000), '1.000G');
    expect(Format.bytesAsReadable(11000000000), '11.00G');
    expect(Format.bytesAsReadable(121000000000), '121.0G');

    expect(Format.bytesAsReadable(1000000000000), '1.000T');
    expect(Format.bytesAsReadable(11000000000000), '11.00T');
    expect(Format.bytesAsReadable(121000000000000), '121.0T');

    expect(Format.bytesAsReadable(1000000000000000), '1e+15');
    expect(Format.bytesAsReadable(11000000000000000), '1e+16');
    expect(Format.bytesAsReadable(121000000000000000), '1e+17');
  });
}
