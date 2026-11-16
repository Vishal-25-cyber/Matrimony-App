import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar_image.dart';
import '../../core/widgets/unlocked_contact_card.dart';
import '../../models/profile_model.dart';
import '../../core/utils/navigation_helper.dart';

class UnlockedContactScreen extends StatelessWidget {
  final ProfileModel profile;

  const UnlockedContactScreen({super.key, required this.profile});

  /// Strips all non-digit characters from a phone string, keeps leading +
  String _cleanPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    return digits;
  }

  /// Shows a dialog with the phone number and a "Dial" button
  void _showPhoneDialog(BuildContext context, String phone) {
    final clean = _cleanPhone(phone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.phone_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Phone Number', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(
          phone,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.call_rounded, size: 18),
            label: const Text('Dial'),
            onPressed: () async {
              Navigator.pop(ctx);
              final uri = Uri(scheme: 'tel', path: clean);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot open dialer for $phone')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  /// Opens WhatsApp chat directly
  Future<void> _openWhatsApp(BuildContext context, String whatsapp) async {
    final clean = _cleanPhone(whatsapp).replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp is not installed on this device.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A132B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: "பின்செல்க / Back",
          onPressed: () => SafeNavigation.safePop(context, initialIndex: 3),
        ),
        title: const Text('தொடர்பு விவரங்கள் / Contact Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Summary Header
            Center(
              child: Column(
                children: [
                  AvatarImage(
                    seed: profile.avatarSeed,
                    name: profile.name,
                    size: 90,
                    isVerified: profile.isVerified,
                    gender: profile.gender,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ID: ${profile.id} • ${profile.occupation}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Unlocked Card
            UnlockedContactCard(
              phone: profile.phone,
              whatsapp: profile.whatsapp,
              email: profile.email,
              onCallTap: () => _showPhoneDialog(context, profile.phone),
              onWhatsAppTap: () => _openWhatsApp(context, profile.whatsapp),
              onEmailTap: () async {
                final uri = Uri(scheme: 'mailto', path: profile.email);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cannot open email for ${profile.email}')),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Tips',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Always involve family members during initial phone or meeting conversations.\n• Verify background details before proceeding further.\n• Do not share financial info.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
