import 'package:flutter/material.dart';
import 'package:flutter_hydrated_login/routes/app_routes.dart';
import 'package:flutter_hydrated_login/screens/home_page.dart';
import 'package:flutter_hydrated_login/screens/login/login_page.dart';

class AppPages {
  static Map<String, Widget Function(BuildContext)> routes() {
    return {
      AppRoutes.HOME: (context) => HomePage(),
      AppRoutes.LOGIN: (context) => LoginPage()
    };
  }
}
