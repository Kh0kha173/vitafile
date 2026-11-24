import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum BadgeType {
  primary,
  medical,
  success,
  warning,
  emergency,
  neutral,
}

class VitaBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final bool isPill;

  const VitaBadge({
    super.key,
    required this.label,
    this.type = BadgeType.primary,
    this.icon,
    this.isPill = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.primary:
        bg = AppColors.primaryTealSoft;
        fg = AppColors.primaryTeal;
        break;
      case BadgeType.medical:
        bg = AppColors.medicalBlueSoft;
        fg = AppColors.medicalBlue;
        break;
      case BadgeType.success:
        bg = AppColors.successGreenSoft;
        fg = AppColors.successGreen;
        break;
      case BadgeType.warning:
        bg = AppColors.warningOrangeSoft;
        fg = AppColors.warningOrange;
        break;
      case BadgeType.emergency:
        bg = AppColors.emergencyRedSoft;
        fg = AppColors.emergencyRed;
        break;
      case BadgeType.neutral:
        bg = AppColors.cardBorderSubtle;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isPill ? 20 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
