import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar_image.dart';
import '../../core/widgets/unlocked_contact_card.dart';
import '../../models/profile_model.dart';
import '../../core/utils/navigation_helper.dart';

class UnlockedContactScreen extends StatelessWidget {
  final ProfileModel profile;

  const UnlockedContactScreen({super.key, required this.profile});

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
              onCallTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dialing ${profile.phone}...')),
                );
              },
              onWhatsAppTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening WhatsApp chat with ${profile.whatsapp}...')),
                );
              },
              onEmailTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening Email client for ${profile.email}...')),
                );
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
