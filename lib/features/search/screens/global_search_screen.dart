import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/search_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() =>
      _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSelect(SearchResultItem item) async {
    switch (item.type) {
      case SearchResultType.lesson:
        context.push('/lesson/${item.id}');
        break;
      case SearchResultType.topic:
        context.push('/roadmap');
        break;
      case SearchResultType.resource:
        final resource = item.originalObject as Resource;
        try {
          final uri = Uri.parse(resource.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (resource.lessonId.isNotEmpty) {
              await ref
                  .read(curriculumProvider.notifier)
                  .markResourceOpened(resource.lessonId, resource.id);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open ${resource.url}')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error launching link: $e')),
            );
          }
        }
        break;
      case SearchResultType.project:
        context.push('/project/${item.id}');
        break;
      case SearchResultType.note:
        context.push('/note-editor?id=${item.id}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search courses, lessons, projects, notes...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintStyle: TextStyle(color: textSecondary),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: textSecondary),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).setQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            ref.read(searchQueryProvider.notifier).setQuery(val);
          },
        ),
      ),
      body: SafeArea(
        child: query.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded,
                        size: 56,
                        color: isDark
                            ? AppColors.textTertiaryDark.withAlpha(80)
                            : AppColors.textTertiaryLight.withAlpha(120)),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      'Search SkillForge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find any programming course, lesson, project, or study note',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : results.isEmpty
                ? Center(
                    child: Text(
                      'No results for "$query"',
                      style: TextStyle(color: textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space20,
                      vertical: AppDimensions.space12,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: AppDimensions.space8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: AppDimensions.radiusMd,
                          border: Border.all(color: borderColor),
                        ),
                        child: ListTile(
                          leading: _buildTypeIcon(item.type),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: textSecondary,
                          ),
                          onTap: () => _handleSelect(item),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildTypeIcon(SearchResultType type) {
    IconData icon;
    Color color;

    switch (type) {
      case SearchResultType.lesson:
        icon = Icons.play_lesson_rounded;
        color = AppColors.primary;
        break;
      case SearchResultType.topic:
        icon = Icons.folder_rounded;
        color = AppColors.accentCyan;
        break;
      case SearchResultType.resource:
        icon = Icons.link_rounded;
        color = AppColors.accentAmber;
        break;
      case SearchResultType.project:
        icon = Icons.laptop_chromebook_rounded;
        color = AppColors.accentPurple;
        break;
      case SearchResultType.note:
        icon = Icons.description_rounded;
        color = AppColors.accentRose;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: AppDimensions.radiusSm,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
