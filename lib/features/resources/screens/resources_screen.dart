import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ResourceType? _selectedCategory; // null = All

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(Resource resource) async {
    final uri = Uri.parse(resource.url);
    try {
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
          SnackBar(content: Text('Error launching URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roadmapRepo = ref.watch(roadmapRepositoryProvider);
    final allResources = roadmapRepo.getAllResources();

    final filtered = allResources.where((r) {
      final matchesQuery = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.provider.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || r.type == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Learning Resources'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space8,
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Search Python, Git, Docker, React...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space8,
              ),
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedCategory == null, () {
                    setState(() => _selectedCategory = null);
                  }),
                  ...ResourceType.values.map((type) {
                    final isSelected = _selectedCategory == type;
                    return _buildFilterChip(type.label, isSelected, () {
                      setState(() => _selectedCategory = type);
                    });
                  }),
                ],
              ),
            ),

            // Resources List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.textTertiaryDark),
                          const SizedBox(height: AppDimensions.space12),
                          Text(
                            'No resources found for "$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space20,
                        vertical: AppDimensions.space8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final resource = filtered[index];
                        return _buildResourceCard(resource);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.darkCard,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.darkBorder,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : AppColors.textSecondaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildResourceCard(Resource resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space10),
      padding: const EdgeInsets.all(AppDimensions.space14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getColor(resource.type).withAlpha(25),
              borderRadius: AppDimensions.radiusSm,
            ),
            child: Icon(
              _getIcon(resource.type),
              color: _getColor(resource.type),
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.space14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      resource.provider,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('•',
                        style: TextStyle(color: AppColors.textTertiaryDark)),
                    const SizedBox(width: 6),
                    Text(
                      resource.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded,
                color: AppColors.primaryLight),
            onPressed: () => _launchUrl(resource),
            tooltip: 'Open resource',
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ResourceType type) {
    switch (type) {
      case ResourceType.youtube:
        return Icons.play_circle_fill_rounded;
      case ResourceType.documentation:
        return Icons.menu_book_rounded;
      case ResourceType.article:
        return Icons.article_rounded;
      case ResourceType.practice:
        return Icons.terminal_rounded;
      case ResourceType.project:
        return Icons.code_rounded;
    }
  }

  Color _getColor(ResourceType type) {
    switch (type) {
      case ResourceType.youtube:
        return const Color(0xFFFF0000);
      case ResourceType.documentation:
        return AppColors.accentCyan;
      case ResourceType.article:
        return AppColors.accentAmber;
      case ResourceType.practice:
        return AppColors.primary;
      case ResourceType.project:
        return AppColors.accentPurple;
    }
  }
}
