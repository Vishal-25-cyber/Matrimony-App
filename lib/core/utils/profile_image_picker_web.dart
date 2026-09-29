// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class ProfileImagePickResult {
  final String fileName;
  final int fileSize;
  final Uint8List bytes;

  ProfileImagePickResult({
    required this.fileName,
    required this.fileSize,
    required this.bytes,
  });
}

Future<ProfileImagePickResult?> pickProfileImage() async {
  final completer = Completer<ProfileImagePickResult?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final resultBytes = reader.result as Uint8List?;
        if (resultBytes != null) {
          completer.complete(
            ProfileImagePickResult(
              fileName: file.name,
              fileSize: file.size,
              bytes: resultBytes,
            ),
          );
        } else {
          completer.complete(null);
        }
      });
      reader.onError.listen((e) {
        completer.complete(null);
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
