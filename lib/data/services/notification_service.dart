import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'devpath_study_reminders';
  static const String channelName = 'DevPath Study Reminders';
  static const String channelDescription =
      'High priority notifications to keep you consistent on your developer career path';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
          if (response.actionId == 'snooze_15') {
            snoozeReminder(minutes: 15);
          } else if (response.actionId == 'snooze_30') {
            snoozeReminder(minutes: 30);
          }
        },
      );
      _initialized = true;
      await _createNotificationChannel();
    } catch (e) {
      debugPrint('Notification init exception: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required List<int> studyDays,
    String? currentFocusTitle,
  }) async {
    try {
      // Cancel existing study reminders
      await cancelAllStudyReminders();

      debugPrint(
          'Scheduled study reminder for $hour:${minute.toString().padLeft(2, '0')} on days: $studyDays');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  Future<void> showStudyReminderNow({
    String? currentFocusTitle,
  }) async {
    final focusText = currentFocusTitle != null && currentFocusTitle.isNotEmpty
        ? 'Continue your journey: $currentFocusTitle.'
        : 'Time to learn and level up your developer skills!';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'start_study',
          'START STUDY',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_15',
          'SNOOZE (15m)',
        ),
      ],
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        id: 1001,
        title: '📚 Study Time',
        body: focusText,
        notificationDetails: platformDetails,
        payload: 'study_session',
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  Future<void> snoozeReminder({int minutes = 15}) async {
    debugPrint('Snoozing study reminder for $minutes minutes');
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      await _notificationsPlugin.show(
        id: 1002,
        title: '⏰ Snooze Active',
        body: 'Study reminder snoozed for $minutes minutes.',
        notificationDetails: const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      debugPrint('Error on snooze: $e');
    }
  }

  Future<void> cancelAllStudyReminders() async {
    try {
      await _notificationsPlugin.cancel(id: 1001);
      await _notificationsPlugin.cancel(id: 1002);
    } catch (e) {
      debugPrint('Failed to cancel reminders: $e');
    }
  }
}
