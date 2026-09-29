import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/profile_model.dart';
import '../../services/mock_data_service.dart';
import 'unlocked_contact_screen.dart';
import '../../core/utils/navigation_helper.dart';

class ContactUnlockScreen extends StatefulWidget {
  final ProfileModel profile;
  final MockDataService mockData;

  const ContactUnlockScreen({
    super.key,
    required this.profile,
    required this.mockData,
  });

  @override
  State<ContactUnlockScreen> createState() => _ContactUnlockScreenState();
}

class _ContactUnlockScreenState extends State<ContactUnlockScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    widget.mockData.unlockContact(widget.profile.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful ✓ Contact Unlocked!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UnlockedContactScreen(
          profile: widget.mockData.getProfileById(widget.profile.id)!,
        ),
      ),
    );
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
        title: const Text('Unlock Contact', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Lock Icon & Visual
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accentGoldLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentGold, width: 2),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 50,
                  color: AppColors.accentGoldDark,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Contact Details 🔒',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.locked.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Private Information',
                  style: TextStyle(
                    color: AppColors.locked,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Contact information for ${widget.profile.name} (${widget.profile.id}) is private to protect user privacy.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Price Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Unlock Contact Fee',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.contactUnlockPrice,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, color: AppColors.success, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Direct Phone, WhatsApp & Email Access',
                          style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Payment Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing Mock Payment...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Unlock Contact Now – ₹99',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Local state mock payment for frontend prototype.',
                style: TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
