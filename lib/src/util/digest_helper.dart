import 'package:convert/convert.dart';

import 'package:crypto/crypto.dart';

/// Extends the Digest class
/// to provide hex encoder/decoder
extension DigestHelper on Digest {
  /// Encode a digest to a hex string.
  String hexEncode(List<int> bytes) => hex.encode(bytes);

  /// Decodes a string that contains a hexidecimal value
  /// into a digest.
  static Digest hexDecode(String hexValue) => Digest(hex.decode(hexValue));
}
