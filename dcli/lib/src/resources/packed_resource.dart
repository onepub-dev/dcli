/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';

import '../../dcli.dart';

/// Base class used by all [PackedResource]s.
abstract class PackedResource {
  /// Creates a resource backed by compressed parts or legacy Base64 content.
  const PackedResource();

  /// Legacy Base64 content. New resources expose compressed [parts] instead.
  /// Use [unpack] for both formats without assembling a file in memory.
  String get content => throw UnsupportedError(
    'This resource uses compressed parts. Use unpack() instead of content.',
  );

  /// Independently compressed parts, in their original order.
  Iterable<PackedResourcePart>? get parts => null;

  Iterable<List<int>> _decodedChunks() sync* {
    final compressedParts = parts;
    if (compressedParts != null) {
      for (final part in compressedParts) {
        final decoded = gzip.decode(base64.decode(part.content));
        if (decoded.length != part.length) {
          throw const FormatException(
            'Packed resource part has an invalid length',
          );
        }
        yield decoded;
      }
      return;
    }
    // Compatibility with existing generated classes containing Base64 lines.
    final encoded = content;
    var start = 0;
    while (start < encoded.length) {
      final newline = encoded.indexOf('\n', start);
      final end = newline == -1 ? encoded.length : newline;
      final line = encoded.substring(start, end).trim();
      if (line.isNotEmpty) {
        yield base64.decode(line);
      }
      start = end + 1;
    }
  }

  /// The checksum of the original file.
  /// You can use this value to see if packed file
  /// is different to a local file without having to unpack
  /// it.
  /// ```dart
  /// calculateHash('/path/to/local/file') == checksum
  /// ```
  String get checksum;

  /// The path to the original file relative to the
  /// packages resource directory.
  String get originalPath;

  /// Unpacks a resource saving it
  /// to the file at [pathTo].
  /// Throws [ResourceException].
  /// @Throwing(ArgumentError)
  /// @Throwing(CreateDirException)
  /// @Throwing(ResourceException)
  /// @Throwing(FormatException)
  /// @Throwing(RangeError)
  void unpack(String pathTo) {
    if (exists(pathTo) && !isFile(pathTo)) {
      throw ResourceException('The unpack target $pathTo must be a file');
    }
    final normalized = normalize(pathTo);
    if (!exists(dirname(normalized))) {
      createDir(dirname(normalized), recursive: true);
    }

    final file = File(normalized).openSync(mode: FileMode.write);

    try {
      // Scan the generated Base64 lines without allocating a list containing
      // every line. A fixed buffer batches the small decoded lines into writes.
      final buffer = Uint8List(64 * 1024);
      var buffered = 0;
      for (final decoded in _decodedChunks()) {
        var offset = 0;
        while (offset < decoded.length) {
          final available = buffer.length - buffered;
          final remaining = decoded.length - offset;
          final count = remaining < available ? remaining : available;
          buffer.setRange(buffered, buffered + count, decoded, offset);
          buffered += count;
          offset += count;
          if (buffered == buffer.length) {
            file.writeFromSync(buffer);
            buffered = 0;
          }
        }
      }
      if (buffered != 0) {
        file.writeFromSync(buffer, 0, buffered);
      }
    } finally {
      file
        ..flushSync()
        ..closeSync();
    }
  }
}

/// One independently gzip-compressed portion of a packed resource.
abstract class PackedResourcePart {
  /// Creates a constant part; generated classes contain at most 256 KiB raw.
  const PackedResourcePart();

  /// Base64-encoded gzip data for this part.
  String get content;

  /// Expected uncompressed length.
  int get length;
}
