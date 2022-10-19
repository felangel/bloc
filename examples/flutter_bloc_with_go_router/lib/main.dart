import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/authentication_bloc.dart';
import 'routes.dart';

void main() => runApp(AuthBloc());

/// Auth Bloc
// ignore: must_be_immutable
class AuthBloc extends StatelessWidget {
  /// Creates a [AuthBloc].
  AuthBloc({Key? key}) : super(key: key);

  /// auth block instance
  AuthenticationBloc authBloc = AuthenticationBloc();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<Bloc<dynamic, dynamic>>>[
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => authBloc,
        ),
        BlocProvider<AppRouter>(
          create: (BuildContext context) => AppRouter(authBloc),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final GoRouter router = context.read<AppRouter>().router;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            title: 'go_router with bloc example',
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
