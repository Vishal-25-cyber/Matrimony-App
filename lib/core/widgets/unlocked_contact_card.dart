import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class UnlockedContactCard extends StatelessWidget {
  final String phone;
  final String whatsapp;
  final String email;
  final VoidCallback onCallTap;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onEmailTap;

  const UnlockedContactCard({
    super.key,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.onCallTap,
    required this.onWhatsAppTap,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.successLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 8),
              Text(
                AppConstants.contactUnlockedText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Phone
          _ContactRow(
            icon: Icons.phone,
            label: "Phone",
            value: phone,
            actionLabel: "Call",
            onTap: onCallTap,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),

          // WhatsApp
          _ContactRow(
            icon: Icons.chat_rounded,
            label: "WhatsApp",
            value: whatsapp,
            actionLabel: "Chat",
            onTap: onWhatsAppTap,
            color: const Color(0xFF25D366),
          ),
          const SizedBox(height: 10),

          // Email
          _ContactRow(
            icon: Icons.email_rounded,
            label: "Email",
            value: email,
            actionLabel: "Email",
            onTap: onEmailTap,
            color: const Color(0xFF1976D2),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onTap;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
