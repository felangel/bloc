import 'package:flutter_bloc_with_navigation/home/home_dialog.dart';
import 'package:flutter_bloc_with_navigation/home/home_details_page.dart';
import 'package:flutter_bloc_with_navigation/home/home_page.dart';
import 'package:flutter_bloc_with_navigation/profile/profile_dialog.dart';
import 'package:flutter_bloc_with_navigation/profile/profile_details_page.dart';
import 'package:flutter_bloc_with_navigation/profile/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateHomeRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.root:
        return CupertinoPageRoute<dynamic>(builder: (_) => const HomePage());
      case AppRoute.details:
        return CupertinoPageRoute<dynamic>(
          builder: (_) => const HomeDetailsPage(),
        );
      case AppRoute.dialog:
        return CupertinoPageRoute<dynamic>(
          builder: (_) => const HomeDialog(),
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> generateProfilesRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoute.root:
        return CupertinoPageRoute<dynamic>(builder: (_) => const ProfilePage());
      case AppRoute.details:
        return CupertinoPageRoute<dynamic>(
          builder: (_) => const ProfileDetailsPage(),
        );
      case AppRoute.dialog:
        return CupertinoPageRoute<dynamic>(
          builder: (_) => const ProfileDialog(),
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) =>
      CupertinoPageRoute<dynamic>(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
}

class AppRoute {
  static const String root = '/';
  static const String details = '/details';
  static const String dialog = '/dialog';
}
