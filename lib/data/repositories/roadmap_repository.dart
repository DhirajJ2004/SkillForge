import '../models/roadmap_models.dart';
import '../services/storage_service.dart';

class RoadmapRepository {
  final StorageService _storage;

  RoadmapRepository(this._storage);

  List<Month> getCurriculum() => _storage.getCurriculum();

  Future<void> saveCurriculum(List<Month> curriculum) async {
    await _storage.saveCurriculum(curriculum);
  }

  Lesson? getLessonById(String lessonId) {
    final curriculum = getCurriculum();
    for (final month in curriculum) {
      for (final topic in month.topics) {
        for (final lesson in topic.lessons) {
          if (lesson.id == lessonId) return lesson;
        }
      }
    }
    return null;
  }

  Future<void> toggleLessonCompletion(String lessonId, bool completed) async {
    final curriculum = getCurriculum();
    final updatedCurriculum = curriculum.map((month) {
      final updatedTopics = month.topics.map((topic) {
        final updatedLessons = topic.lessons.map((lesson) {
          if (lesson.id == lessonId) {
            return lesson.copyWith(
              completed: completed,
              completedAt: completed ? DateTime.now() : null,
            );
          }
          return lesson;
        }).toList();
        return topic.copyWith(lessons: updatedLessons);
      }).toList();
      return month.copyWith(topics: updatedTopics);
    }).toList();

    await saveCurriculum(updatedCurriculum);
  }

  Future<void> toggleLessonBookmark(String lessonId, bool isBookmarked) async {
    final curriculum = getCurriculum();
    final updatedCurriculum = curriculum.map((month) {
      final updatedTopics = month.topics.map((topic) {
        final updatedLessons = topic.lessons.map((lesson) {
          if (lesson.id == lessonId) {
            return lesson.copyWith(isBookmarked: isBookmarked);
          }
          return lesson;
        }).toList();
        return topic.copyWith(lessons: updatedLessons);
      }).toList();
      return month.copyWith(topics: updatedTopics);
    }).toList();

    await saveCurriculum(updatedCurriculum);
  }

  List<Lesson> getBookmarkedLessons() {
    final curriculum = getCurriculum();
    final List<Lesson> bookmarks = [];
    for (final month in curriculum) {
      for (final topic in month.topics) {
        for (final lesson in topic.lessons) {
          if (lesson.isBookmarked) {
            bookmarks.add(lesson);
          }
        }
      }
    }
    return bookmarks;
  }

  Future<void> markResourceOpened(String lessonId, String resourceId) async {
    final curriculum = getCurriculum();
    final updatedCurriculum = curriculum.map((month) {
      final updatedTopics = month.topics.map((topic) {
        final updatedLessons = topic.lessons.map((lesson) {
          if (lesson.id == lessonId) {
            final updatedResources = lesson.resources.map((r) {
              if (r.id == resourceId) {
                return r.copyWith(opened: true);
              }
              return r;
            }).toList();
            return lesson.copyWith(resources: updatedResources);
          }
          return lesson;
        }).toList();
        return topic.copyWith(lessons: updatedLessons);
      }).toList();
      return month.copyWith(topics: updatedTopics);
    }).toList();

    await saveCurriculum(updatedCurriculum);
  }

  Lesson? getFirstIncompleteLesson() {
    final curriculum = getCurriculum();
    for (final month in curriculum) {
      for (final topic in month.topics) {
        for (final lesson in topic.lessons) {
          if (!lesson.completed) {
            return lesson;
          }
        }
      }
    }
    return null;
  }

  List<Lesson> getTodaysPlan(int dailyGoalMinutes) {
    final curriculum = getCurriculum();
    final List<Lesson> plan = [];
    int totalMinutes = 0;

    for (final month in curriculum) {
      for (final topic in month.topics) {
        for (final lesson in topic.lessons) {
          if (!lesson.completed) {
            plan.add(lesson);
            totalMinutes += lesson.estimatedMinutes;
            if (totalMinutes >= dailyGoalMinutes && plan.length >= 2) {
              return plan;
            }
            if (plan.length >= 4) {
              return plan;
            }
          }
        }
      }
    }

    // If all completed or fewer items left
    return plan;
  }

  List<Resource> getAllResources() {
    final curriculum = getCurriculum();
    final List<Resource> list = [];
    for (final month in curriculum) {
      for (final topic in month.topics) {
        for (final lesson in topic.lessons) {
          list.addAll(lesson.resources);
        }
      }
    }
    return list;
  }
}
