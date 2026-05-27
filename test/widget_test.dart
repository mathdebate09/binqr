import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:binqr/core/binqr_encoder.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

BinQRChunk _buildChunk(Uint8List bytes, int index, int total) {
  final checksum = md5.convert(bytes).toString();
  final data = base64Encode(bytes);
  return BinQRChunk(index: index, total: total, checksum: checksum, data: data);
}

Future<File> _tempFileWithBytes(List<int> bytes, String name) async {
  final dir = await Directory.systemTemp.createTemp('binqr_test_');
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  await file.writeAsBytes(bytes);
  return file;
}

void main() {
  group('BinQRMetadata', () {
    test('round-trips to and from QR string', () {
      final metadata = BinQRMetadata(
        appName: 'binqr',
        fileName: 'sample',
        fileExtension: '.txt',
        fileSize: 42,
        totalChunks: 3,
      );

      final qr = metadata.toQRString();
      final parsed = BinQRMetadata.fromQRString(qr);

      expect(parsed.appName, metadata.appName);
      expect(parsed.fileName, metadata.fileName);
      expect(parsed.fileExtension, metadata.fileExtension);
      expect(parsed.fileSize, metadata.fileSize);
      expect(parsed.totalChunks, metadata.totalChunks);
      expect(BinQRMetadata.isMetadata(qr), isTrue);
      expect(BinQRMetadata.isMetadata('not-json'), isFalse);
    });
  });

  group('BinQRChunk', () {
    test('parses and validates checksum', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final chunk = _buildChunk(bytes, 0, 1);
      final parsed = BinQRChunk.fromQRString(chunk.toQRString());

      expect(parsed, isNotNull);
      expect(parsed!.index, 0);
      expect(parsed.total, 1);
      expect(parsed.isValid, isTrue);
      expect(parsed.rawBytes, bytes);
    });

    test('rejects invalid data or checksum', () {
      final bytes = Uint8List.fromList([5, 6, 7]);
      final chunk = _buildChunk(bytes, 0, 1);
      final badChecksum = BinQRChunk(
        index: 0,
        total: 1,
        checksum: 'deadbeef',
        data: chunk.data,
      );
      final badData = BinQRChunk(
        index: 0,
        total: 1,
        checksum: chunk.checksum,
        data: '!!not-base64!!',
      );

      expect(badChecksum.isValid, isFalse);
      expect(badData.isValid, isFalse);
    });
  });

  group('BinQREncoder', () {
    test('creates metadata + chunk count across boundaries', () async {
      final sizes = [0, 1999, 2000, 2001, 4000, 4001];

      for (final size in sizes) {
        final bytes = List<int>.generate(size, (i) => i % 256);
        final file = await _tempFileWithBytes(bytes, 'sample.bin');
        final qrStrings = BinQREncoder.encode(file);

        final metadata = BinQRMetadata.fromQRString(qrStrings.first);
        final expectedTotal = (size / kChunkSize).ceil();

        expect(metadata.totalChunks, expectedTotal);
        expect(qrStrings.length, expectedTotal + 1);

        for (int i = 1; i < qrStrings.length; i++) {
          final chunk = BinQRChunk.fromQRString(qrStrings[i]);
          expect(chunk, isNotNull);
          expect(chunk!.isValid, isTrue);
        }
      }
    });
  });

  group('BinQRDecoder', () {
    test('reconstructs original bytes from chunks', () {
      final bytes = Uint8List.fromList(
        List<int>.generate(kChunkSize * 2 + 123, (i) => i % 256),
      );
      final totalChunks = (bytes.length / kChunkSize).ceil();
      final metadata = BinQRMetadata(
        appName: 'binqr',
        fileName: 'sample',
        fileExtension: '.bin',
        fileSize: bytes.length,
        totalChunks: totalChunks,
      );
      final decoder = BinQRDecoder(metadata);

      final chunks = <BinQRChunk>[];
      for (int i = 0; i < totalChunks; i++) {
        final start = i * kChunkSize;
        final end = (start + kChunkSize).clamp(0, bytes.length);
        final chunkBytes = bytes.sublist(start, end);
        chunks.add(_buildChunk(Uint8List.fromList(chunkBytes), i, totalChunks));
      }

      expect(decoder.isComplete, isFalse);
      expect(decoder.missingIndices, [0, 1, 2]);

      decoder.addChunk(chunks[1]);
      expect(decoder.isComplete, isFalse);
      expect(decoder.progress, closeTo(1 / totalChunks, 0.0001));
      expect(decoder.missingIndices, [0, 2]);

      decoder.addChunk(chunks[0]);
      decoder.addChunk(chunks[2]);

      expect(decoder.isComplete, isTrue);
      expect(decoder.missingIndices, isEmpty);
      expect(decoder.assemble(), bytes);
      expect(decoder.addChunk(chunks[0]), isFalse);
    });

    test('rejects invalid chunks', () {
      final metadata = BinQRMetadata(
        appName: 'binqr',
        fileName: 'sample',
        fileExtension: '.bin',
        fileSize: 3,
        totalChunks: 1,
      );
      final decoder = BinQRDecoder(metadata);
      final badChunk = BinQRChunk(
        index: 0,
        total: 1,
        checksum: 'deadbeef',
        data: base64Encode([1, 2, 3]),
      );

      expect(decoder.addChunk(badChunk), isFalse);
      expect(decoder.isComplete, isFalse);
    });
  });
}
