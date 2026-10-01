import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class ActivityCalendar extends StatelessWidget {
  final Map<DateTime, int> activityMap;

  const ActivityCalendar({
    super.key,
    required this.activityMap,
  });

  Color _getIntensityColor(int minutes, bool isDark) {
    if (minutes == 0) {
      return isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0);
    }
    if (minutes < 20) return const Color(0xFF1E3A8A);
    if (minutes < 45) return const Color(0xFF1D4ED8);
    if (minutes < 60) return AppColors.primary;
    return const Color(0xFF60A5FA);
  }

  void _showDayDetails(BuildContext context, DateTime day, int minutes) {
    final formattedDate =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusLg,
          side: BorderSide(color: AppColors.darkBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Time: $minutes minutes',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              minutes >= 20
                  ? 'Streak maintained for this day! 🔥'
                  : minutes > 0
                      ? 'Study recorded.'
                      : 'No study recorded on this date.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate grid for past 10 weeks (70 days)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Align to Sunday/Monday
    final days = List.generate(70, (index) {
      return today.subtract(Duration(days: 69 - index));
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textTertiary =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDimensions.radiusLg,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Activity (Last 10 Weeks)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Less ',
                    style: TextStyle(
                      fontSize: 10,
                      color: textTertiary,
                    ),
                  ),
                  _LegendSquare(
                      color: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFE2E8F0)),
                  const SizedBox(width: 2),
                  const _LegendSquare(color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 2),
                  const _LegendSquare(color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 2),
                  const _LegendSquare(color: AppColors.primary),
                  Text(
                    ' More',
                    style: TextStyle(
                      fontSize: 10,
                      color: textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space14),

          // GitHub-style grid: 7 rows (days of week), 10 columns (weeks)
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final dayKey = DateTime(day.year, day.month, day.day);
                final minutes = activityMap[dayKey] ?? 0;
                final isCurrentDay = day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;

                return GestureDetector(
                  onTap: () => _showDayDetails(context, day, minutes),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getIntensityColor(minutes, isDark),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isCurrentDay
                            ? AppColors.primaryLight
                            : borderColor,
                        width: isCurrentDay ? 1.2 : 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendSquare extends StatelessWidget {
  final Color color;
  const _LegendSquare({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
