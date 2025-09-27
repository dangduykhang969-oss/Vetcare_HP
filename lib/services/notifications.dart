import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  static final NotiService _i = NotiService._();
  NotiService._();
  factory NotiService() => _i;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: android);
    await _plugin.initialize(init);

    const channel = AndroidNotificationChannel(
      'vetcare_channel', 'VetCare Notifications',
      description: 'Nhắc cắt chỉ & báo cáo', importance: Importance.high);
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleOneTime(int id, DateTime when, {
    String title = 'Nhắc cắt chỉ',
    required String body,
  }) async {
    final tzTime = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vetcare_channel', 'VetCare Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> scheduleDailySummary({int hour = 7, int minute = 30}) async {
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (first.isBefore(now)) {
      first = first.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      999999,
      'Báo cáo hôm nay',
      'Chạm để xem danh sách đến hạn cắt chỉ.',
      first,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'vetcare_channel', 'VetCare Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
