import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../services/storage_service.dart';

class NotesRepository {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  NotesRepository(this._storage);

  List<Note> getNotes() => _storage.getNotes();

  List<Note> getNotesForLesson(String lessonId) {
    return getNotes().where((n) => n.lessonId == lessonId).toList();
  }

  Note? getNoteById(String id) {
    try {
      return getNotes().firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Note> saveNote({
    String? id,
    required String lessonId,
    required String lessonTitle,
    required String title,
    required String content,
  }) async {
    final notes = getNotes();
    final now = DateTime.now();

    if (id != null && id.isNotEmpty) {
      final index = notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        // Edit existing
        final existing = notes[index];
        final updatedNote = existing.copyWith(
          lessonId: lessonId.isNotEmpty ? lessonId : existing.lessonId,
          lessonTitle: lessonTitle.isNotEmpty ? lessonTitle : existing.lessonTitle,
          title: title,
          content: content,
          updatedAt: now,
        );
        notes[index] = updatedNote;
        await _storage.saveNotes(notes);
        return updatedNote;
      }
    }

    // Create new
    final newNote = Note(
      id: (id != null && id.isNotEmpty) ? id : _uuid.v4(),
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    notes.insert(0, newNote);
    await _storage.saveNotes(notes);
    return newNote;
  }

  Future<void> deleteNote(String id) async {
    final notes = getNotes();
    notes.removeWhere((n) => n.id == id);
    await _storage.saveNotes(notes);
  }
}
