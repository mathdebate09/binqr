import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileStorage {
  /// Saves bytes to app's external files dir under a BinQR subfolder.
  /// This requires NO extra permissions on Android 10+ (API 29+).
  /// Path: /sdcard/Android/data/com.example.binqr_app/files/BinQR/
  /// Visible in file manager under "Internal Storage > Android > data > ... > files > BinQR"
  static Future<String> save({
    required Uint8List bytes,
    required String fileName,
    required String extension,
  }) async {
    final dir = await _binqrDir();
    final name = _uniqueName(dir, fileName, extension);
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<Directory> _binqrDir() async {
    Directory base;
    if (Platform.isAndroid) {
      base = (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    } else {
      base = await getApplicationDocumentsDirectory();
    }
    final binqr = Directory(p.join(base.path, 'BinQR'));
    if (!binqr.existsSync()) await binqr.create(recursive: true);
    return binqr;
  }

  static String _uniqueName(Directory dir, String name, String ext) {
    var candidate = '$name$ext';
    var counter = 1;
    while (File(p.join(dir.path, candidate)).existsSync()) {
      candidate = '$name($counter)$ext';
      counter++;
    }
    return candidate;
  }
}