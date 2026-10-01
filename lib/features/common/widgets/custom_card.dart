import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool hasGlow;
  final Color? glowColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.space16),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = backgroundColor ??
        (isDark ? AppColors.darkCard : AppColors.lightCard);
    final border = borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    Widget content = Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(
          color: border,
          width: AppDimensions.borderWidth,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: glowColor ?? AppColors.primaryGlow,
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppDimensions.radiusMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.radiusMd,
          splashColor: AppColors.primary.withAlpha(20),
          highlightColor: AppColors.primary.withAlpha(10),
          child: content,
        ),
      );
    }

    return content;
  }
}
