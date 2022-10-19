import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'bloc/authentication_bloc.dart';
import 'bloc/authentication_event.dart';
import 'bloc/authentication_state.dart';
import 'pages/error_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

/// routes
class AppRouter extends Bloc<AuthenticationEvent, AuthenticationState> {
  /// create routes with authentication bloc
  AppRouter(this.authBloc) : super(const AuthenticationInitial());

  /// use authentication bloc for use navigation
  late final AuthenticationBloc authBloc;

  /// save previous state
  AuthenticationState? prevAuthState;

  /// getter
  GoRouter get router => _goRouter;

  late final GoRouter _goRouter = GoRouter(
    redirect: (BuildContext context, GoRouterState state) async {
      if (prevAuthState == authBloc.state) {
        return null;
      }
      prevAuthState = authBloc.state;
      if (authBloc.state is AuthenticationAuthenticated) {
        debugPrint('Authenticated');
        return '/home';
      } else if (authBloc.state is AuthenticationUnAuthenticated) {
        debugPrint('UnAuthenticated');
        return '/login';
      } else if (authBloc.state is AuthenticationUnknown) {
        debugPrint('AuthenticationUnknown');
      }
      debugPrint('no return somethings');
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: <RouteBase>[
      GoRoute(
          path: '/',
          redirect: (_, __) {
            if (authBloc.state is AuthenticationAuthenticated) {
              return '/home';
            } else {
              return '/login';
            }
          }),
      GoRoute(
        path: '/home',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return MaterialPage<dynamic>(
            key: state.pageKey,
            child: const HomePage(),
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return MaterialPage<dynamic>(
            key: state.pageKey,
            child: const LoginPage(),
          );
        },
      ),
    ],
    errorPageBuilder: (BuildContext context, GoRouterState state) {
      return MaterialPage<dynamic>(
        key: state.pageKey,
        child: ErrorPage(exception: state.error),
      );
    },
    debugLogDiagnostics: true,
  );
}

/// stream to use go_router refreshListen
class GoRouterRefreshStream extends ChangeNotifier {
  /// notify to all subscribers.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
