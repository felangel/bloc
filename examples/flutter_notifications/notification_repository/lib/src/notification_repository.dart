import 'dart:async';
import 'entities/entities.dart';

/// This is an abstraction for notifications, it handles scheduling notifications and exposing a stream of notifications,
/// which a bloc can listen to and trigger UI changes.
abstract class NotificationRepository {
  Future<void> initialize();
  Stream<NotificationEntity> get notificationStream;
  void dispose();
}
