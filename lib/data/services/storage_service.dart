import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/roadmap_models.dart';
import '../models/study_session.dart';
import '../models/project_model.dart';
import '../models/note_model.dart';
import '../seeds/curriculum_seed.dart';
import '../seeds/projects_seed.dart';

class StorageService {
  static const String _keyProfile = 'devpath_profile';
  static const String _keyCurriculum = 'devpath_curriculum';
  static const String _keySessions = 'devpath_study_sessions';
  static const String _keyProjects = 'devpath_projects';
  static const String _keyNotes = 'devpath_notes';
  static const String _keyThemeMode = 'devpath_theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._ensureInitialized();
    return service;
  }

  Future<void> _ensureInitialized() async {
    // Seed curriculum if not present
    if (!_prefs.containsKey(_keyCurriculum)) {
      final initialCurriculum = CurriculumSeed.getInitialCurriculum();
      await saveCurriculum(initialCurriculum);
    }

    // Seed projects if not present
    if (!_prefs.containsKey(_keyProjects)) {
      final initialProjects = ProjectsSeed.getInitialProjects();
      await saveProjects(initialProjects);
    }

    // Seed default user profile if not present
    if (!_prefs.containsKey(_keyProfile)) {
      await saveProfile(UserProfile.defaultProfile());
    }
  }

  // --- Profile ---
  UserProfile getProfile() {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null) return UserProfile.defaultProfile();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (e) {
      debugPrint('Error parsing user profile: $e');
      return UserProfile.defaultProfile();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  // --- Curriculum & Lessons ---
  List<Month> getCurriculum() {
    final raw = _prefs.getString(_keyCurriculum);
    if (raw == null) return CurriculumSeed.getInitialCurriculum();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Month.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing curriculum: $e');
      return CurriculumSeed.getInitialCurriculum();
    }
  }

  Future<void> saveCurriculum(List<Month> curriculum) async {
    final list = curriculum.map((m) => m.toJson()).toList();
    await _prefs.setString(_keyCurriculum, jsonEncode(list));
  }

  // --- Study Sessions ---
  List<StudySession> getStudySessions() {
    final raw = _prefs.getString(_keySessions);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => StudySession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing study sessions: $e');
      return [];
    }
  }

  Future<void> saveStudySessions(List<StudySession> sessions) async {
    final list = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(_keySessions, jsonEncode(list));
  }

  Future<void> addStudySession(StudySession session) async {
    final sessions = getStudySessions();
    sessions.insert(0, session);
    await saveStudySessions(sessions);
  }

  // --- Projects ---
  List<Project> getProjects() {
    final raw = _prefs.getString(_keyProjects);
    if (raw == null) return ProjectsSeed.getInitialProjects();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing projects: $e');
      return ProjectsSeed.getInitialProjects();
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    final list = projects.map((p) => p.toJson()).toList();
    await _prefs.setString(_keyProjects, jsonEncode(list));
  }

  // --- Notes ---
  List<Note> getNotes() {
    final raw = _prefs.getString(_keyNotes);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing notes: $e');
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final list = notes.map((n) => n.toJson()).toList();
    await _prefs.setString(_keyNotes, jsonEncode(list));
  }

  // --- Theme Mode ---
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'dark';
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // --- Export & Import Backup ---
  String exportAllDataJson() {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': getProfile().toJson(),
      'curriculum': getCurriculum().map((m) => m.toJson()).toList(),
      'studySessions': getStudySessions().map((s) => s.toJson()).toList(),
      'projects': getProjects().map((p) => p.toJson()).toList(),
      'notes': getNotes().map((n) => n.toJson()).toList(),
      'themeMode': getThemeMode(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importDataJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }
      final Map<String, dynamic> data = decoded;
      if (data.isEmpty) return false;

      UserProfile? parsedProfile;
      List<Month>? parsedCurriculum;
      List<StudySession>? parsedSessions;
      List<Project>? parsedProjects;
      List<Note>? parsedNotes;
      String? parsedTheme;

      if (data['profile'] != null) {
        parsedProfile = UserProfile.fromJson(data['profile'] as Map<String, dynamic>);
      }
      if (data['curriculum'] != null) {
        parsedCurriculum = (data['curriculum'] as List<dynamic>)
            .map((e) => Month.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['studySessions'] != null) {
        parsedSessions = (data['studySessions'] as List<dynamic>)
            .map((e) => StudySession.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['projects'] != null) {
        parsedProjects = (data['projects'] as List<dynamic>)
            .map((e) => Project.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['notes'] != null) {
        parsedNotes = (data['notes'] as List<dynamic>)
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['themeMode'] != null && data['themeMode'] is String) {
        parsedTheme = data['themeMode'] as String;
      }

      // Ensure at least one valid key was found
      if (parsedProfile == null &&
          parsedCurriculum == null &&
          parsedSessions == null &&
          parsedProjects == null &&
          parsedNotes == null) {
        return false;
      }

      // Atomic commit: all parsed successfully without throwing
      if (parsedProfile != null) await saveProfile(parsedProfile);
      if (parsedCurriculum != null) await saveCurriculum(parsedCurriculum);
      if (parsedSessions != null) await saveStudySessions(parsedSessions);
      if (parsedProjects != null) await saveProjects(parsedProjects);
      if (parsedNotes != null) await saveNotes(parsedNotes);
      if (parsedTheme != null) await saveThemeMode(parsedTheme);

      return true;
    } catch (e) {
      debugPrint('Error importing data JSON: $e');
      return false;
    }
  }

  // --- Reset Progress ---
  Future<void> resetAllProgress() async {
    // Reset curriculum to clean uncompleted state
    final initialCurriculum = CurriculumSeed.getInitialCurriculum();
    await saveCurriculum(initialCurriculum);

    // Reset projects to uncompleted tasks
    final initialProjects = ProjectsSeed.getInitialProjects();
    await saveProjects(initialProjects);

    // Clear study sessions
    await saveStudySessions([]);

    // Clear notes
    await saveNotes([]);

    // Reset profile progress dates while keeping user preferences
    final profile = getProfile();
    await saveProfile(profile.copyWith(
      createdAt: DateTime.now(),
    ));
  }
}
