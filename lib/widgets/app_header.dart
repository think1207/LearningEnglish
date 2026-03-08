import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final IconData leftIcon;
  final VoidCallback? onLeftIconPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.leftIcon = Icons.arrow_back,
    this.onLeftIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(leftIcon, color: AppColors.textDark),
            onPressed: onLeftIconPressed ?? () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 12),
                  subtitleWidget!,
                ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
