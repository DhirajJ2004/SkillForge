# SkillForge

> A modern, production-grade learning platform for mastering practical software engineering skills through structured roadmaps, interactive practice drills, real-world portfolio projects, and deterministic progress tracking.

---

## 🌟 Overview

**SkillForge** is an educational mobile application built with Flutter and Riverpod. It bridges the gap between tutorial hell and production readiness by guiding learners through a rigorous 6-month engineering curriculum:

1. **Month 1:** Python Fundamentals, Data Structures & Scripting
2. **Month 2:** Modern Web Development (Semantic HTML, Modern CSS, Responsive JavaScript)
3. **Month 3:** Backend Engineering & Databases (FastAPI, Relational SQL, REST Architecture)
4. **Month 4:** Applied AI Engineering (RAG Pipelines, Vector Search, LLM Agent Workflows)
5. **Month 5:** DevOps & Cloud Deployment (Linux, Docker Containers, CI/CD, AWS Cloud)
6. **Month 6:** Production Engineering & Career Readiness (Data Structures, System Design, Technical Interviews)

---

## ✨ Features

- **Personalized Home Dashboard:**
  - Dynamic greeting and daily goal tracking (`todayStudyMinutes` vs `dailyGoalMinutes`).
  - Hero "Continue Learning" card pointing directly to current active lesson.
  - Interactive "Today's Plan" checklist with idempotent completion toggling.
  - Quick-stats summary tracking streak, total study hours, and completed curriculum count.
- **Interactive Career Roadmap:**
  - Connected visual progression graph with discrete milestone statuses (`LOCKED`, `AVAILABLE`, `IN PROGRESS`, `COMPLETED`).
  - Toggle between Visual Timeline Path and Detailed Module Accordion views.
- **Practice & Assessment Hub:**
  - Multi-category technical drills across Python, SQL, JavaScript, FastAPI, and DSA.
  - Real-time question evaluation with instant feedback and explanations.
  - Automated weak-area and strong-area detection based on historical attempts.
  - Historical practice attempt logging with accuracy and duration.
- **Deterministic XP & Gamification:**
  - Deterministic XP calculation: XP rewarded for completed lessons, projects, tasks, quizzes, streaks, and focus time.
  - Level progression from *Novice Developer* to *Lead Architect*.
  - 8 core deterministic achievement badges (*First Step*, *Dedicated Learner*, *7-Day Streak*, *Builder*, *Milestone Finisher*, *Quiz Ace*, *Problem Solver*, *Deep Focus*).
- **Study Focus Timer:**
  - Deep work timer integrated directly into curriculum lessons with session history.
- **Portfolio Projects Showcase:**
  - 6 production portfolio specifications with task-by-task completion checklists, repository URLs, live URLs, and architecture notes.
- **Personal Lesson Notes:**
  - Contextual note-taking attached to specific curriculum lessons with full CRUD persistence.
- **Offline Data Persistence & Hygiene:**
  - Structured local JSON persistence via SharedPreferences.
  - Full JSON backup export and restore capabilities.
  - Safe, confirmed progress reset mechanism that preserves user settings.
- **Privacy & Notification Architecture:**
  - Daily inexact reminders using `AndroidScheduleMode.inexact` (no battery-draining exact alarm permissions).
  - Clean manifest without dangerous permissions (e.g. `android.permission.DUMP` verified absent).

---

## 🏗️ Architecture & Tech Stack

```
lib/
├── core/
│   ├── constants/       # AppColors, AppDimensions, AppTheme
│   └── routing/         # GoRouter configuration & routes
├── data/
│   ├── models/          # Roadmap, Practice, Achievement, Project, User, Notes
│   ├── repositories/    # RoadmapRepository, PracticeRepository, ProjectRepository, etc.
│   ├── seeds/           # Cleaned curriculum, real portfolio projects & resources
│   └── services/        # StorageService (JSON persistence), NotificationService
├── features/
│   ├── common/          # Shared widgets (CustomButton, CourseCard, HeroCard)
│   ├── dashboard/       # Home dashboard, greeting header, stats row, today's goal card
│   ├── learn/           # Category filter, course browser, career paths
│   ├── roadmap/         # Interactive graph tree, month accordion, lesson detail
│   ├── practice/        # Technical quiz engine, attempt recorder, weak-area analytics
│   ├── projects/        # Portfolio project cards, task checklists, detail editor
│   ├── progress/        # XP tracker, activity calendar, readiness evaluation
│   ├── profile/         # Learner rank, achievement grid, quick hubs
│   └── settings/        # Theme switcher, study reminders, backup & reset tools
└── providers/           # Riverpod state notifiers and derived selectors
```

- **Framework:** Flutter 3.44+ (Channel Stable)
- **Language:** Dart 3.12+
- **State Management:** Flutter Riverpod (Notifier & NotifierProvider architecture)
- **Navigation:** GoRouter 17+
- **Local Persistence:** SharedPreferences with JSON serialization
- **Notifications:** `flutter_local_notifications` (Android 13+ runtime permissions & inexact scheduling)
- **URL Launcher:** `url_launcher` for verified external documentation links

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0 or higher recommended)
- Android Studio / Android SDK (API level 34+)
- VS Code or Antigravity IDE with Flutter & Dart extensions

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DhirajJ2004/SkillForge.git
   cd SkillForge
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify analyzer hygiene:**
   ```bash
   flutter analyze
   ```

4. **Run the test suite:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing

SkillForge maintains an extensive test suite covering unit models, business logic, state repositories, and UI widgets:

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/skillforge_unit_test.dart

# Run widget tests only
flutter test test/skillforge_widget_test.dart
```

### Test Coverage Highlights
- **XP Calculation & Progression:** Deterministic formula verification, milestone title graduation.
- **Achievement Evaluation:** Real criteria triggers, progress ratio calculation.
- **Practice Analytics:** Accuracy calculation, weak/strong category classification.
- **Bookmarking & Idempotency:** Repeated lesson completion safety, bookmark toggles.
- **Roadmap Node Status:** Dynamic state resolution (`locked`, `available`, `inProgress`, `completed`).
- **Widget Integration:** Header greeting, goal cards, checklist interactions, visual timeline nodes.

---

## 📦 Production Release Build

To build an optimized release APK:

```bash
flutter build apk --release
```

Output binary:
`build/app/outputs/flutter-apk/app-release.apk`

To build an Android App Bundle for Google Play deployment:

```bash
flutter build appbundle --release
```

---

## 🔒 Security & Permissions Review

- **`android.permission.DUMP`:** Removed / verified absent from all manifests.
- **Exact Alarms:** `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` were removed in favor of `AndroidScheduleMode.inexact` for daily study reminders, eliminating Google Play declaration hurdles.
- **No Hardcoded Credentials:** Zero API keys, secrets, or tokens stored in source code.
- **Safe External URLs:** Demo/mock Vercel URLs replaced with legitimate educational resources and user-editable project endpoints.

---

## 🗺️ Roadmap & Next Steps

- [x] SkillForge identity & professional UI/UX theme overhaul
- [x] Inexact study notifications with Android 13+ permission support
- [x] Interactive visual roadmap progression graph
- [x] Deterministic XP & Achievement system
- [x] Real practice attempt persistence & weak-topic diagnostics
- [x] JSON backup & restore with safe progress reset
- [ ] Cloud sync via Supabase / Firebase (optional user account link)
- [ ] Interactive in-app code editor & runner for practice drills

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
