import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules timer-completion alerts when the app is backgrounded mid-workout.
class WorkoutTimerNotificationService {
  WorkoutTimerNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool enabled = true;
  bool _initialized = false;

  static const _channelId = 'workout_timer_channel';
  static const _channelName = 'Workout Timers';
  static const restNotificationId = 9101;
  static const exerciseNotificationId = 9102;

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Rest and exercise timer alerts during workouts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
  );

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Rest and exercise timer alerts during workouts',
      importance: Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleRestComplete({
    required int secondsFromNow,
    String? exerciseName,
  }) async {
    if (!enabled || !_initialized || secondsFromNow <= 0) return;
    await _schedule(
      id: restNotificationId,
      title: 'Rest over',
      body: exerciseName == null
          ? 'Time for your next set'
          : 'Next up: $exerciseName',
      secondsFromNow: secondsFromNow,
    );
  }

  Future<void> scheduleExerciseComplete({
    required int secondsFromNow,
    required String exerciseName,
  }) async {
    if (!enabled || !_initialized || secondsFromNow <= 0) return;
    await _schedule(
      id: exerciseNotificationId,
      title: '$exerciseName finished',
      body: 'Log your set and take a rest',
      secondsFromNow: secondsFromNow,
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required int secondsFromNow,
  }) async {
    try {
      await cancel(id: id);
      final scheduled = tz.TZDateTime.now(tz.local).add(
        Duration(seconds: secondsFromNow),
      );
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e, s) {
      Log.error('WorkoutTimerNotificationService: schedule failed',
          error: e, stackTrace: s);
    }
  }

  Future<void> cancel({required int id}) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: id);
    } catch (e, s) {
      Log.error('WorkoutTimerNotificationService: cancel failed',
          error: e, stackTrace: s);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: restNotificationId);
      await _plugin.cancel(id: exerciseNotificationId);
    } catch (e, s) {
      Log.error('WorkoutTimerNotificationService: cancelAll failed',
          error: e, stackTrace: s);
    }
  }
}
