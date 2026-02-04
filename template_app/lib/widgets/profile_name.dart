
import 'package:flutter/material.dart';
import 'package:template_app/values/colors.dart';

class ProfileName extends StatelessWidget {
  const ProfileName({
    super.key,
    required this.theme,
    required this.isLightMode,
  });

  final ThemeData theme;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isLightMode ? [AppColors.lightShadow] : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
    
          // AVATAR
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: AppColors.avatarPlaceholder,
              shape: BoxShape.circle,
            ),
          ),
    
          const SizedBox(width: 12),
    
          // NAME AND ROLE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TESTTEST',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ROLE',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
