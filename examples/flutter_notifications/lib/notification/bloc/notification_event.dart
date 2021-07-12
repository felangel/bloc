part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class NotificationReceived extends NotificationEvent {
  NotificationReceived(this.notificationEntity);
  final NotificationEntity notificationEntity;

  @override
  List<Object> get props => [notificationEntity];
}
