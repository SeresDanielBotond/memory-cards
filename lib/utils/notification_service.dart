import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton: only one instance of this class will ever exist.
  // Access it anywhere with NotificationService.instance
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // SharedPreferences keys
  static const _enabledKey = 'reminder_enabled';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  /// Call this once when the app starts (in main.dart)
  Future<void> init() async {
    tz.initializeTimeZones();
    // The timezone package starts in UTC. Set the local time zone of the course
    // (Germany) — otherwise the reminder arrives one or two hours late.
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Ask the user to allow notifications (needed on Android 13+).
  /// Returns true if notifications are allowed.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Read the saved reminder state from storage
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Read the saved reminder time from storage
  Future<({int hour, int minute})> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return (
    hour: prefs.getInt(_hourKey) ?? 20,
    minute: prefs.getInt(_minuteKey) ?? 0,
    );
  }

  /// Schedule a daily reminder and save the state
  Future<void> scheduleReminder(int hour, int minute) async {
    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);

    // Calculate the next occurrence of this time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0, // notification ID
      'Memory Cards',
      'Time to write today\'s memory!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Reminds you to write a memory each day',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Cancel the reminder and save the state
  Future<void> cancelReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    await _plugin.cancel(0);
  }
}