import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

const int kChunkSize = 2000;

/// Metadata QR payload — sent as QR index -1 (first QR shown)
class BinQRMetadata {
  final String appName;
  final String fileName;
  final String fileExtension;
  final int fileSize;
  final int totalChunks;

  BinQRMetadata({
    required this.appName,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
    required this.totalChunks,
  });

  String toQRString() => jsonEncode({
    'app': appName,
    'name': fileName,
    'ext': fileExtension,
    'size': fileSize,
    'total': totalChunks,
    'type': 'meta',
  });

  static BinQRMetadata fromQRString(String raw) {
    final m = jsonDecode(raw);
    return BinQRMetadata(
      appName: m['app'],
      fileName: m['name'],
      fileExtension: m['ext'],
      fileSize: m['size'],
      totalChunks: m['total'],
    );
  }

  static bool isMetadata(String raw) {
    try {
      final m = jsonDecode(raw);
      return m['type'] == 'meta';
    } catch (_) {
      return false;
    }
  }
}

/// A single data chunk QR payload
class BinQRChunk {
  final int index;
  final int total;
  final String checksum; // MD5 of raw bytes
  final String data; // base64 encoded bytes

  BinQRChunk({
    required this.index,
    required this.total,
    required this.checksum,
    required this.data,
  });

  String toQRString() => '$index|$total|$checksum|$data';

  static BinQRChunk? fromQRString(String raw) {
    try {
      final parts = raw.split('|');
      if (parts.length < 4) return null;
      return BinQRChunk(
        index: int.parse(parts[0]),
        total: int.parse(parts[1]),
        checksum: parts[2],
        data: parts.sublist(3).join('|'), // data may contain |
      );
    } catch (_) {
      return null;
    }
  }

  bool get isValid {
    try {
      final bytes = base64Decode(data);
      final hash = md5.convert(bytes).toString();
      return hash == checksum;
    } catch (_) {
      return false;
    }
  }

  Uint8List get rawBytes => base64Decode(data);
}

/// Encodes a file into a list of QR strings (metadata + chunks)
class BinQREncoder {
  static List<String> encode(File file) {
    final bytes = file.readAsBytesSync();
    final fileName = p.basenameWithoutExtension(file.path);
    final ext = p.extension(file.path); // includes dot e.g. ".jpg"
    final total = (bytes.length / kChunkSize).ceil();

    final metadata = BinQRMetadata(
      appName: 'BinQR',
      fileName: fileName,
      fileExtension: ext,
      fileSize: bytes.length,
      totalChunks: total,
    );

    final qrStrings = <String>[metadata.toQRString()];

    for (int i = 0; i < total; i++) {
      final start = i * kChunkSize;
      final end = (start + kChunkSize).clamp(0, bytes.length);
      final chunk = bytes.sublist(start, end);
      final b64 = base64Encode(chunk);
      final checksum = md5.convert(chunk).toString();

      qrStrings.add(
        BinQRChunk(
          index: i,
          total: total,
          checksum: checksum,
          data: b64,
        ).toQRString(),
      );
    }

    return qrStrings;
  }
}

/// Assembles received chunks into a file
class BinQRDecoder {
  final BinQRMetadata metadata;
  final Map<int, Uint8List> _chunks = {};

  BinQRDecoder(this.metadata);

  /// Returns true if chunk was new and valid, false if duplicate or invalid
  bool addChunk(BinQRChunk chunk) {
    if (_chunks.containsKey(chunk.index)) return false; // duplicate
    if (!chunk.isValid) return false; // bad checksum
    _chunks[chunk.index] = chunk.rawBytes;
    return true;
  }

  bool hasChunk(int index) => _chunks.containsKey(index);

  int get receivedCount => _chunks.length;
  int get totalCount => metadata.totalChunks;
  double get progress => totalCount == 0 ? 0 : receivedCount / totalCount;
  bool get isComplete => receivedCount == totalCount;

  List<int> get missingIndices {
    if (totalCount == 0) return const [];
    final missing = <int>[];
    for (int i = 0; i < totalCount; i++) {
      if (!_chunks.containsKey(i)) missing.add(i);
    }
    return missing;
  }

  /// Assembles and returns the final file bytes
  Uint8List assemble() {
    final sorted = List.generate(totalCount, (i) => _chunks[i]!);
    final total = sorted.fold<int>(0, (sum, b) => sum + b.length);
    final result = Uint8List(total);
    int offset = 0;
    for (final chunk in sorted) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return result;
  }
}
