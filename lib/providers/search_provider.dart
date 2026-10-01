import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

enum SearchResultType { lesson, topic, resource, project, note }

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final dynamic originalObject;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.originalObject,
  });
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final searchResultsProvider = Provider<List<SearchResultItem>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return [];

  final List<SearchResultItem> results = [];
  final curriculum = ref.watch(curriculumProvider);
  final projects = ref.watch(projectsProvider);
  final notes = ref.watch(notesProvider);

  // Search in Curriculum (Months, Topics, Lessons, Resources)
  for (final month in curriculum) {
    for (final topic in month.topics) {
      if (topic.title.toLowerCase().contains(query) ||
          topic.description.toLowerCase().contains(query)) {
        results.add(SearchResultItem(
          id: topic.id,
          title: topic.title,
          subtitle: 'Topic • ${month.title}',
          type: SearchResultType.topic,
          originalObject: topic,
        ));
      }

      for (final lesson in topic.lessons) {
        if (lesson.title.toLowerCase().contains(query) ||
            lesson.description.toLowerCase().contains(query)) {
          results.add(SearchResultItem(
            id: lesson.id,
            title: lesson.title,
            subtitle: 'Lesson • ${topic.title}',
            type: SearchResultType.lesson,
            originalObject: lesson,
          ));
        }

        for (final resource in lesson.resources) {
          if (resource.title.toLowerCase().contains(query) ||
              resource.provider.toLowerCase().contains(query)) {
            results.add(SearchResultItem(
              id: resource.id,
              title: resource.title,
              subtitle: '${resource.type.label} • ${resource.provider}',
              type: SearchResultType.resource,
              originalObject: resource,
            ));
          }
        }
      }
    }
  }

  // Search in Projects
  for (final project in projects) {
    final techMatch =
        project.technologies.any((t) => t.toLowerCase().contains(query));
    if (project.title.toLowerCase().contains(query) ||
        project.description.toLowerCase().contains(query) ||
        techMatch) {
      results.add(SearchResultItem(
        id: project.id,
        title: project.title,
        subtitle:
            'Project • Month ${project.monthNumber} • ${project.technologies.take(2).join(', ')}',
        type: SearchResultType.project,
        originalObject: project,
      ));
    }
  }

  // Search in Notes
  for (final note in notes) {
    if (note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query) ||
        note.lessonTitle.toLowerCase().contains(query)) {
      results.add(SearchResultItem(
        id: note.id,
        title: note.title,
        subtitle: 'Note • ${note.lessonTitle}',
        type: SearchResultType.note,
        originalObject: note,
      ));
    }
  }

  return results;
});
