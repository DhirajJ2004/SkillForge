import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/custom_button.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String? initialLessonId;
  final String? initialLessonTitle;

  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.initialLessonId,
    this.initialLessonTitle,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _lessonId = '';
  String _lessonTitle = 'General Notes';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _lessonId = widget.initialLessonId ?? '';
    _lessonTitle = widget.initialLessonTitle ?? 'General Notes';

    if (widget.noteId != null && widget.noteId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notes = ref.read(notesProvider);
        try {
          final note = notes.firstWhere((n) => n.id == widget.noteId);
          _titleController.text = note.title;
          _contentController.text = note.content;
          setState(() {
            _lessonId = note.lessonId;
            _lessonTitle = note.lessonTitle;
          });
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter note content')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(notesProvider.notifier).saveNote(
            id: widget.noteId,
            lessonId: _lessonId,
            lessonTitle: _lessonTitle,
            title: title.isEmpty ? 'Untitled Note' : title,
            content: content,
          );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null && widget.noteId!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            children: [
              // Topic / Context Tag
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: AppDimensions.radiusSm,
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_outline_rounded,
                        size: 16, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lessonTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space14),

              // Title
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Note Title',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16, vertical: 12),
                ),
              ),
              const SizedBox(height: AppDimensions.space14),

              // Body
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimaryDark,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'Write explanations, code snippets, syntax rules, or personal reminders...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              CustomButton(
                text: isEditing ? 'Save Changes' : 'Create Note',
                isFullWidth: true,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveNote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
