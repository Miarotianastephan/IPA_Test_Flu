import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/system_notification.dart';
import 'package:live_app/provider/api_provider.dart';

class SystemNotificationState {
  final List<SystemNotification> notifications;
  final bool isLoading;
  final String? error;

  SystemNotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  SystemNotificationState copyWith({
    List<SystemNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return SystemNotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  SystemNotification? get lastNotification =>
      notifications.isNotEmpty ? notifications.first : null;
}

class SystemNotificationNotifier
    extends StateNotifier<SystemNotificationState> {
  final Ref ref;

  SystemNotificationNotifier(this.ref) : super(SystemNotificationState());

  /// Add a new notification (avoid duplicates)
  void addNotification(SystemNotification notification) {
    final exists = state.notifications.any((n) => n.id == notification.id);
    if (exists) {
      return;
    }

    final updatedList = [notification, ...state.notifications];
    state = state.copyWith(notifications: updatedList);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    // Optimistic update (update UI immediately)
    final updatedList = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
    state = state.copyWith(notifications: updatedList);

    // Sync with backend
    try {
      final messageService = ref.read(messageServiceProvider);
      await messageService.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Update system_notification_provider.dart
  Future<void> markAsRead(int notificationId) async {
    // Optimistic update (update UI immediately)
    final updatedList = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updatedList);

    // Sync with backend
    try {
      final messageService = ref.read(messageServiceProvider);
      await messageService.markNotificationAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      // Could revert the optimistic update here if needed
    }
  }

  // Update system_notification_provider.dart
  Future<void> removeNotification(int notificationId) async {
    // Optimistic update
    final updatedList = state.notifications
        .where((n) => n.id != notificationId)
        .toList();
    state = state.copyWith(notifications: updatedList);

    // Sync with backend
    try {
      final messageService = ref.read(messageServiceProvider);
      await messageService.deleteNotification(notificationId: notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Load notifications from server
  Future<void> loadNotifications({
    int page = 1,
    int limit = 50,
    bool refresh = false,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final messageService = ref.read(messageServiceProvider);
      final response = await messageService.getNotifications(
        page: page,
        limit: limit,
      );
      if (response.code == 1) {
        final notifications = response.data?.list ?? [];

        if (refresh || page == 1) {
          // If refreshing or loading first page, replace all notifications
          state = state.copyWith(
            notifications: notifications,
            isLoading: false,
            error: null,
          );
        } else {
          // If loading more pages, merge with existing notifications, avoiding duplicates
          final existingIds = state.notifications.map((n) => n.id).toSet();
          final newNotifications = notifications
              .where((n) => !existingIds.contains(n.id))
              .toList();

          final updatedList = [...state.notifications, ...newNotifications];

          state = state.copyWith(
            notifications: updatedList,
            isLoading: false,
            error: null,
          );
        }
      } else {
        state = state.copyWith(isLoading: false, error: response.msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('Error loading notifications: $e');
    }
  }
}

final systemNotificationProvider =
    StateNotifierProvider<SystemNotificationNotifier, SystemNotificationState>(
      (ref) => SystemNotificationNotifier(ref),
    );
