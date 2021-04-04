import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notifications/notification/bloc/notification_bloc.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationRecieveSuccess) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.notificationModel.title),
                  subtitle: Text(state.notificationModel.body),
                );
              });
        }
        return Center(child: Text('no notifications'));
      },
    );
  }
}
