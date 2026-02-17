import 'dart:math';

/// UUID v4 generator utility.
///
/// Generates RFC 4122 compliant UUIDs without external dependencies.
///
/// Example:
/// ```dart
/// final uuid = UuidGenerator.v4();
/// print(uuid); // "550e8400-e29b-41d4-a716-446655440000"
/// ```
class UuidGenerator {
  static final Random _random = Random.secure();

  /// Generate a random UUID v4 (RFC 4122 compliant).
  ///
  /// Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  /// where x is any hexadecimal digit and y is one of 8, 9, A, or B
  static String v4() {
    // Generate 16 random bytes
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Set version (4) in byte 6
    bytes[6] = (bytes[6] & 0x0f) | 0x40;

    // Set variant (10xx) in byte 8
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    // Convert to hex string with hyphens
    return '${_bytesToHex(bytes, 0, 4)}-'
        '${_bytesToHex(bytes, 4, 6)}-'
        '${_bytesToHex(bytes, 6, 8)}-'
        '${_bytesToHex(bytes, 8, 10)}-'
        '${_bytesToHex(bytes, 10, 16)}';
  }

  /// Generate deterministic UUID from string (for project IDs).
  ///
  /// Uses string hash to create reproducible UUIDs for same input.
  /// Useful for mapping file paths to consistent project IDs.
  ///
  /// Example:
  /// ```dart
  /// final uuid1 = UuidGenerator.fromString('/path/to/project');
  /// final uuid2 = UuidGenerator.fromString('/path/to/project');
  /// assert(uuid1 == uuid2); // Same path = same UUID
  /// ```
  static String fromString(String input) {
    // Use input hash as seed for reproducible UUID
    final hash = input.hashCode;
    final rng = Random(hash);

    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));

    // Set version (4) and variant
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return '${_bytesToHex(bytes, 0, 4)}-'
        '${_bytesToHex(bytes, 4, 6)}-'
        '${_bytesToHex(bytes, 6, 8)}-'
        '${_bytesToHex(bytes, 8, 10)}-'
        '${_bytesToHex(bytes, 10, 16)}';
  }

  /// Convert bytes to hex string.
  static String _bytesToHex(List<int> bytes, int start, int end) {
    final buffer = StringBuffer();
    for (var i = start; i < end; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
