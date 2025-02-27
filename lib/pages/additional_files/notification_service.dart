import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

//notification settings

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    bool? initialized = await _notificationsPlugin.initialize(initSettings);
    print("Notification plugin initialized: ${initialized ?? false}");

    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print("Permission denied for notifications");
        return;
      }
    }
  }

  //immediate notification
  static Future<void> showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'This channel is for instant notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, details);
    print("Instant notification shown");
  }

  //notification for a certain time
  static Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('The reminder time is in the past!');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'This channel is used for note reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("Scheduled notification set for: $tzScheduledTime");
  }

  //cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print("Notification with ID $id cancelled");
  }
}
