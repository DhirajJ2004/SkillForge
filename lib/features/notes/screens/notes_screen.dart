import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/note_model.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/empty_state.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);

    final filtered = notes.where((n) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.lessonTitle.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Study Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_rounded, color: AppColors.primary),
            onPressed: () => context.push('/note-editor'),
            tooltip: 'New Note',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (notes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space20,
                  vertical: AppDimensions.space8,
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Search notes by topic or keyword...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() => _query = val.trim());
                  },
                ),
              ),
            ],
            Expanded(
              child: notes.isEmpty
                  ? EmptyState(
                      icon: Icons.note_alt_outlined,
                      title: 'Nothing here yet',
                      description:
                          'Save useful explanations, code patterns, and tips while you learn.',
                      buttonText: 'Create First Note',
                      onButtonPressed: () => context.push('/note-editor'),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No notes match "$_query"',
                            style: const TextStyle(
                                color: AppColors.textSecondaryDark),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space20,
                            vertical: AppDimensions.space8,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final note = filtered[index];
                            return _buildNoteCard(note);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space10),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppDimensions.radiusMd,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: InkWell(
        onTap: () {
          context.push('/note-editor?id=${note.id}');
        },
        borderRadius: AppDimensions.radiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                    onPressed: () {
                      ref.read(notesProvider.notifier).deleteNote(note.id);
                    },
                    tooltip: 'Delete note',
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: AppDimensions.radiusSm,
                ),
                child: Text(
                  note.lessonTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
