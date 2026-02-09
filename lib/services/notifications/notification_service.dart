import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:lotto_vision/presentation/providers/notification_provider.dart';
import 'package:lotto_vision/services/notifications/notification_constants.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    await _initializeLocalNotifications();
    await _initializeRemoteNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(payload: response.payload);
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        notificationChannelId,
        notificationChannelName,
        description: notificationChannelDescription,
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initializeRemoteNotifications() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (kDebugMode) {
      debugPrint('[Notifications] FCM token: $token');
    }

    FirebaseMessaging.onMessage.listen(_onRemoteMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteMessageOpened);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _onRemoteMessageOpened(initialMessage);
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final details = _notificationDetails();
    await _localNotifications.show(
      _nextId(),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    final details = _notificationDetails();
    final scheduleDate = tz.TZDateTime.from(scheduledAt, tz.local);
    await _localNotifications.zonedSchedule(
      _nextId(),
      title,
      body,
      scheduleDate,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      notificationChannelName,
      channelDescription: notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  void _onRemoteMessage(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Lottery update';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'Tap to view details';

    _recordInAppNotification(message, title, body);
    showLocalNotification(title: title, body: body);
  }

  void _onRemoteMessageOpened(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Lottery update';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'Tap to view details';

    _recordInAppNotification(message, title, body);
  }

  void _recordInAppNotification(
    RemoteMessage message,
    String title,
    String body,
  ) {
    final kind = _kindFromMessage(message);
    _ref.read(notificationsProvider.notifier).addNotification(
          AppNotification(
            id: message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            message: body,
            createdAt: DateTime.now(),
            kind: kind,
          ),
        );
  }

  NotificationKind _kindFromMessage(RemoteMessage message) {
    final raw = message.data['type']?.toString().toLowerCase().trim();
    switch (raw) {
      case 'result':
        return NotificationKind.result;
      case 'win':
        return NotificationKind.win;
      case 'ticket':
        return NotificationKind.ticket;
      case 'system':
        return NotificationKind.system;
      default:
        return NotificationKind.system;
    }
  }

  void _handleNotificationTap({String? payload}) {
    if (kDebugMode) {
      debugPrint('[Notifications] tapped payload: $payload');
    }
  }

  int _nextId() => DateTime.now().millisecondsSinceEpoch.remainder(100000);
}
