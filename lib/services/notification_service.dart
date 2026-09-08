import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );
  }

  static Future<void> requestPermission() async {
    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_tracker_channel',
      'Expense Tracker',
      channelDescription: 'Expense Tracker local notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_tracker_reminder_channel',
      'Expense Tracker Reminders',
      channelDescription: 'Daily expense reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    await _notifications.zonedSchedule(
      id: 1001,
      title: 'Expense Reminder',
      body: 'Don\'t forget to check and update your expenses.',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }


}