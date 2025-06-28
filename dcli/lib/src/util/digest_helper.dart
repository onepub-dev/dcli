/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:convert/convert.dart';

import 'package:crypto/crypto.dart';

/// Extends the Digest class
/// to provide hex encoder/decoder
extension DigestHelper on Digest {
  /// Encode a digest to a hex string.
  String hexEncode() => hex.encode(bytes);

  /// Decodes a string that contains a hexidecimal value
  /// into a digest.
  static Digest hexDecode(String hexValue) => Digest(hex.decode(hexValue));
}
