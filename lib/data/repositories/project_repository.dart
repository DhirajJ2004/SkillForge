import '../models/project_model.dart';
import '../services/storage_service.dart';

class ProjectRepository {
  final StorageService _storage;

  ProjectRepository(this._storage);

  List<Project> getProjects() => _storage.getProjects();

  Project? getProjectById(String id) {
    final projects = getProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleTask(String projectId, String taskId, bool completed) async {
    final projects = getProjects();
    final updated = projects.map((p) {
      if (p.id == projectId) {
        final updatedTasks = p.tasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(completed: completed);
          }
          return t;
        }).toList();
        return p.copyWith(tasks: updatedTasks);
      }
      return p;
    }).toList();

    await _storage.saveProjects(updated);
  }

  Future<void> updateProjectUrlsAndNotes({
    required String projectId,
    required String githubUrl,
    required String liveUrl,
    required String notes,
  }) async {
    final projects = getProjects();
    final updated = projects.map((p) {
      if (p.id == projectId) {
        return p.copyWith(
          githubUrl: githubUrl,
          liveUrl: liveUrl,
          notes: notes,
        );
      }
      return p;
    }).toList();

    await _storage.saveProjects(updated);
  }

  int getCompletedProjectsCount() {
    return getProjects().where((p) => p.isCompleted).length;
  }
}
