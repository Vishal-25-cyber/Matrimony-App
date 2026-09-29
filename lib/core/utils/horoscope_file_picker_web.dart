// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class HoroscopeFilePickResult {
  final String fileName;
  final int fileSize;
  final Uint8List? bytes;
  final String? inferredStar;
  final String? inferredRasi;

  HoroscopeFilePickResult({
    required this.fileName,
    required this.fileSize,
    this.bytes,
    this.inferredStar,
    this.inferredRasi,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

Future<HoroscopeFilePickResult?> pickHoroscopeDocument({required bool isBride}) async {
  final completer = Completer<HoroscopeFilePickResult?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*,.pdf';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final resultBytes = reader.result as Uint8List?;
        completer.complete(
          HoroscopeFilePickResult(
            fileName: file.name,
            fileSize: file.size,
            bytes: resultBytes,
          ),
        );
      });
      reader.onError.listen((e) {
        completer.complete(
          HoroscopeFilePickResult(
            fileName: file.name,
            fileSize: file.size,
          ),
        );
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
