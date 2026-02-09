import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationKind { result, win, ticket, system }

const bool kSeedNotifications = false;

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationKind kind;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.kind,
    this.isRead = false,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      kind: kind,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
      : super(kDebugMode && kSeedNotifications ? _seedNotifications() : []);

  static List<AppNotification> _seedNotifications() {
    if (!kDebugMode) {
      return [];
    }
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'result-1',
        title: 'Mahajana results are ready',
        message: 'Draw #2345 is available. Check your ticket now.',
        createdAt: now.subtract(const Duration(hours: 2)),
        kind: NotificationKind.result,
      ),
      AppNotification(
        id: 'win-1',
        title: 'Winning ticket detected',
        message: 'Your Mega Power ticket won a prize. Tap for details.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        kind: NotificationKind.win,
      ),
      AppNotification(
        id: 'scan-1',
        title: 'Scan completed',
        message: 'We extracted your ticket numbers. Review them before checking.',
        createdAt: now.subtract(const Duration(days: 3)),
        kind: NotificationKind.ticket,
        isRead: true,
      ),
    ];
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }

  void markRead(String id) {
    state = [
      for (final item in state)
        item.id == id ? item.copyWith(isRead: true) : item,
    ];
  }

  void markAllRead() {
    state = [
      for (final item in state)
        item.isRead ? item : item.copyWith(isRead: true),
    ];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});
