import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonType { primary, secondary, gold, outlined }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (type) {
      case ButtonType.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case ButtonType.secondary:
        bg = AppColors.primaryContainer;
        fg = AppColors.primary;
        break;
      case ButtonType.gold:
        bg = AppColors.accentGold;
        fg = AppColors.textPrimary;
        break;
      case ButtonType.outlined:
        bg = Colors.transparent;
        fg = AppColors.primary;
        border = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: type == ButtonType.outlined ? 0 : 2,
          shadowColor: bg.withValues(alpha: 0.3),
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: fg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
