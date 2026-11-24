import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum VitaButtonVariant {
  primaryTeal,
  medicalBlue,
  emergencyRed,
  outline,
  ghost,
}

class VitaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final VitaButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isFullWidth;

  const VitaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = VitaButtonVariant.primaryTeal,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Decoration? decoration;
    Color textColor = AppColors.white;
    BorderSide? border;

    switch (variant) {
      case VitaButtonVariant.primaryTeal:
        decoration = BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
        break;
      case VitaButtonVariant.medicalBlue:
        decoration = BoxDecoration(
          gradient: AppColors.blueTealGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.medicalBlue.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
        break;
      case VitaButtonVariant.emergencyRed:
        decoration = BoxDecoration(
          gradient: AppColors.emergencyGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.emergencyRed.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
        break;
      case VitaButtonVariant.outline:
        textColor = AppColors.primaryTeal;
        border = const BorderSide(color: AppColors.primaryTeal, width: 1.5);
        break;
      case VitaButtonVariant.ghost:
        textColor = AppColors.textSecondary;
        break;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );

    if (decoration != null) {
      return Container(
        width: isFullWidth ? double.infinity : width,
        height: height,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(child: content),
          ),
        ),
      );
    }

    if (border != null) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120), height),
          side: border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: content,
      );
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(isFullWidth ? double.infinity : (width ?? 120), height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: content,
    );
  }
}
