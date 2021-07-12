import 'package:equatable/equatable.dart';
import 'package:notification_repository/notification_repository.dart';

class NotificationModel extends Equatable {
  NotificationModel({this.title = '', this.body = '', required this.id, this.hasInteracted = false});

  final String title;
  final String body;
  final int id;
  final bool hasInteracted;

  factory NotificationModel.fromEntity(NotificationEntity notificationEntity) {
    return NotificationModel(
        title: notificationEntity.title,
        body: notificationEntity.body,
        id: notificationEntity.id,
        hasInteracted: notificationEntity.hasInteracted);
  }

  @override
  List<Object?> get props => [title, body, id];
}
