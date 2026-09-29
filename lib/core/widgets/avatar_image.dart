import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../services/cloudflare_r2_service.dart';

class AvatarImage extends StatelessWidget {
  final String seed;
  final String name;
  final double size;
  final bool isOnline;
  final bool isVerified;
  final String? gender;
  final Uint8List? imageBytes;
  final String? imageUrl;

  const AvatarImage({
    super.key,
    required this.seed,
    required this.name,
    this.size = 60,
    this.isOnline = false,
    this.isVerified = false,
    this.gender,
    this.imageBytes,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final isBride = gender?.toLowerCase() == 'bride';
    final primaryBgColor = isBride ? const Color(0xFF8C2C41) : AppColors.primary;
    final secondaryBgColor = isBride ? const Color(0xFFD9A441) : AppColors.primaryDark;
    final hasCustomBytes = imageBytes != null && imageBytes!.isNotEmpty;
    final resolvedUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? CloudflareR2Service().ensureDisplayableUrl(imageUrl!)
        : null;
    final hasCustomUrl = resolvedUrl != null && resolvedUrl.trim().isNotEmpty;
    final hasCustomImage = hasCustomBytes || hasCustomUrl;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasCustomImage
                ? null
                : LinearGradient(
                    colors: [primaryBgColor, secondaryBgColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: AppColors.accentGold, width: size > 70 ? 2.5 : 1.5),
          ),
          child: ClipOval(
            child: hasCustomBytes
                ? Image.memory(
                    imageBytes!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : hasCustomUrl
                    ? Image.network(
                        resolvedUrl,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isBride ? Icons.person_3_rounded : Icons.person_rounded,
                                color: AppColors.accentGoldLight.withValues(alpha: 0.9),
                                size: size * 0.42,
                              ),
                              if (size >= 50)
                                Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size * 0.2,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isBride ? Icons.person_3_rounded : Icons.person_rounded,
                              color: AppColors.accentGoldLight.withValues(alpha: 0.9),
                              size: size * 0.42,
                            ),
                            if (size >= 50)
                              Text(
                                initials,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size * 0.2,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        if (isVerified && !isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Color(0xFF1976D2),
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'M';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
