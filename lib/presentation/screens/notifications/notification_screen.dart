import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';
import 'package:lotto_vision/presentation/providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (unreadCount > 0)
            IconButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              tooltip: 'Mark all read',
              icon: const Icon(Icons.done_all),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const _EmptyNotificationsState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return _NotificationCard(
                    notification: item,
                    onTap: () => ref
                        .read(notificationsProvider.notifier)
                        .markRead(item.id),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive notifications about lottery results here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconForKind(notification.kind);
    final iconColor = _colorForKind(context, notification.kind);
    final iconBg = iconColor.withOpacity(0.15);
    final titleStyle = notification.isRead
        ? theme.textTheme.titleMedium
        : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(notification.title, style: titleStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              _formatTimestamp(notification.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: notification.isRead ? null : const _UnreadDot(),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

IconData _iconForKind(NotificationKind kind) {
  switch (kind) {
    case NotificationKind.result:
      return Icons.emoji_events;
    case NotificationKind.win:
      return Icons.card_giftcard;
    case NotificationKind.ticket:
      return Icons.confirmation_number;
    case NotificationKind.system:
      return Icons.notifications;
  }
}

Color _colorForKind(BuildContext context, NotificationKind kind) {
  switch (kind) {
    case NotificationKind.win:
      return Colors.green.shade600;
    case NotificationKind.ticket:
      return Colors.orange.shade700;
    case NotificationKind.system:
      return Theme.of(context).colorScheme.secondary;
    case NotificationKind.result:
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

String _formatTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final sameDay = now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day;
  if (sameDay) {
    return DateFormat.jm().format(dateTime);
  }
  return DateFormat.MMMd().add_jm().format(dateTime);
}
