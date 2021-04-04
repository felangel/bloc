import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationEntity extends Equatable {
  NotificationEntity({required this.id, this.body = '', this.title = '', this.hasInteracted = false});

  final bool hasInteracted;
  final int id;
  final String body;
  final String title;

  factory NotificationEntity.fromRemoteMessage(RemoteMessage remoteMessage) {
    NotificationEntity notificationEntity = NotificationEntity(
        id: remoteMessage.messageId.hashCode,
        title: remoteMessage.notification?.title ?? '',
        body: remoteMessage.notification?.body ?? '');
    return notificationEntity;
  }

  @override
  List<Object?> get props => [body, title];
}
