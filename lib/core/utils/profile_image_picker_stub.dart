import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

/// Shows a bottom-sheet on mobile to choose Gallery or Camera,
/// then picks the image and returns bytes.
Future<ProfileImagePickResult?> pickProfileImage({BuildContext? context}) async {
  if (const bool.fromEnvironment('FLUTTER_TEST')) {
    // Transparent 1x1 PNG for headless test runners
    final sampleBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);
    return ProfileImagePickResult(
      fileName: 'profile_photo.png',
      fileSize: sampleBytes.length,
      bytes: sampleBytes,
    );
  }

  // Ask user to pick source (Gallery or Camera) via bottom sheet if context provided
  ImageSource? source = ImageSource.gallery;
  if (context != null && context.mounted) {
    source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Photo Source',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C161A),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF7A132B),
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF1B6B38),
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  if (source == null) {
    if (kDebugMode) print('📷 [ImagePicker] User dismissed source picker');
    return null;
  }

  try {
    if (kDebugMode) print('📷 [ImagePicker] Launching picker with source: $source');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      if (kDebugMode) {
        print('📷 [ImagePicker] Picked file: ${pickedFile.name}, path: ${pickedFile.path}');
      }
      final bytes = await pickedFile.readAsBytes();
      if (kDebugMode) print('📷 [ImagePicker] Read ${bytes.length} bytes successfully');
      return ProfileImagePickResult(
        fileName: pickedFile.name.isNotEmpty ? pickedFile.name : 'avatar.jpg',
        fileSize: bytes.length,
        bytes: bytes,
      );
    } else {
      if (kDebugMode) print('📷 [ImagePicker] No file selected (user cancelled)');
    }
  } catch (e, st) {
    if (kDebugMode) {
      print('⚠ [ImagePicker] Error: $e');
      print('⚠ [ImagePicker] StackTrace: $st');
    }
    rethrow;
  }
  return null;
}

/// Button widget used in the source-selection bottom sheet
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
