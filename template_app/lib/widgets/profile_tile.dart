import 'package:flutter/material.dart';
import 'package:template_app/values/colors.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.context,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final BuildContext context;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Material(
      color: theme.listTileTheme.tileColor,
      borderRadius: BorderRadius.circular(12),
      elevation: isLight ? 4 : 0,
      shadowColor: isLight ? AppColors.lightShadow.color : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, size: 28, color: theme.iconTheme.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.accent,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
