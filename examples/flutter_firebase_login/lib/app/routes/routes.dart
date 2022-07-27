import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_login/app/app.dart';
import 'package:flutter_firebase_login/home/home.dart';
import 'package:flutter_firebase_login/login/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
