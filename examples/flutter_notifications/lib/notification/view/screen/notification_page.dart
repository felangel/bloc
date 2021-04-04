import 'package:flutter/material.dart';
import 'package:flutter_notifications/notification/view/widgets/widgets.dart';

class NotificationPage extends StatelessWidget {
  static String routeName = 'Notification_page_route';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: NotificationList(),
    );
  }
}
