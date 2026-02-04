import 'package:flutter/material.dart';
import 'package:template_app/values/colors.dart';

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.listTileTheme.tileColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLight ? [AppColors.lightShadow] : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Icon placeholder
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),

          // Text placeholder
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Arrow placeholder
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
