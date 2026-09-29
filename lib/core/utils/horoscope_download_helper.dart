import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'file_downloader.dart';
import '../../models/profile_model.dart';

class HoroscopeDownloadHelper {
  static Future<bool> downloadHoroscopeCertificate({
    required BuildContext context,
    required GlobalKey boundaryKey,
    required ProfileModel profile,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("சான்றிதழ் பதிவு தயாரிப்பதில் பிழை ஏற்பட்டது."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false;
      }

      // Render at high resolution (2.5x) for clean printing/saving
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final bytes = byteData.buffer.asUint8List();
      final cleanName = profile.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = "${profile.id}_${cleanName}_Horoscope.png";

      downloadFileFromBytes(bytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download_done_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ஜாதகக் குறிப்பு வெற்றிகரமாக பதிவிறக்கப்பட்டது! ✓",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        fileName,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFF0D68A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B6B38),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("பதிவிறக்கம் தோல்வி: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }
}
