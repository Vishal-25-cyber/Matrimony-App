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
  final defaultName = isBride ? "Bride_Horoscope_Chart.png" : "Groom_Horoscope_Chart.png";
  return HoroscopeFilePickResult(
    fileName: defaultName,
    fileSize: 1024 * 285, // ~285 KB
    bytes: Uint8List(0),
    inferredStar: isBride ? "ரோகிணி (Rohini)" : "மிருகசீரிஷம் (Mrigashirsha)",
    inferredRasi: isBride ? "ரிஷபம் (Rishabham)" : "ரிஷபம் (Rishabham)",
  );
}
