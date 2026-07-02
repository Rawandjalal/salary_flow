import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — navigate to tasks page if needed
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermission() async {
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true; // Android handles permission differently
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return false;
    }
  }

  /// Schedule a local notification for when the task is due.
  Future<void> scheduleTaskNotification(FinancialTask task) async {
    if (!_initialized) await init();

    final now = DateTime.now();
    if (task.dueDateTime.isBefore(now)) return; // Already past

    // Cancel any existing notification for this task
    await cancelTaskNotification(task.id);

    final notifId = task.id.hashCode.abs() % 100000;

    final amountText = task.amount != null
        ? ' — \$${task.amount!.toStringAsFixed(2)}'
        : '';

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    const androidDetails = AndroidNotificationDetails(
      'salary_flow_tasks',
      'Task Reminders',
      channelDescription: 'Reminders for your financial tasks',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      notifId,
      '${task.category.emoji} Task Due: ${task.title}',
      'Your task is due now!$amountText',
      tz.TZDateTime.from(task.dueDateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );

    debugPrint('Scheduled notification $notifId for task ${task.title} at ${task.dueDateTime}');
  }

  Future<void> cancelTaskNotification(String taskId) async {
    if (!_initialized) await init();
    final notifId = taskId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }


  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
