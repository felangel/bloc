import 'package:flutter/material.dart';

import 'notification/view/screen/notification_page.dart';

class HomePage extends StatelessWidget {
  static String routeName = 'home_page_route';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context,NotificationPage.routeName);
              })
        ],
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
