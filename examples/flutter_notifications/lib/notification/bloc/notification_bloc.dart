import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_notifications/notification/models/notification.dart';
import 'package:notification_repository/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';


/// A Bloc that listens to [NotificationRepository]'s notificationStream, and add a [NotificationReceived] event
/// in response to new notification received.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    _notificationSubscription = _notificationRepository.notificationStream
        .listen((NotificationEntity notificationEntity) {
      add(NotificationReceived(notificationEntity));
    });
  }

  final NotificationRepository _notificationRepository;
  late StreamSubscription<NotificationEntity> _notificationSubscription;
  @override
  Stream<NotificationState> mapEventToState(
    NotificationEvent event,
  ) async* {
    if (event is NotificationReceived) {
      yield await _mapNotificationReveivedToState(event);
    }
  }

  Future<NotificationState> _mapNotificationReveivedToState(
      NotificationReceived event) async {
    final notificationEntity = event.notificationEntity;
    return NotificationRecieveSuccess(
        NotificationModel.fromEntity(notificationEntity));
  }

  @override
  Future<void> close() {
    _notificationRepository.dispose();
    _notificationSubscription.cancel();
    return super.close();
  }
}
