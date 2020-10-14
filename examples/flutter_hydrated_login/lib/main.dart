import 'package:flutter/material.dart';
import 'package:flutter_hydrated_login/bloc/auth/bloc.dart';
import 'package:flutter_hydrated_login/bloc/bloc_%20watcher.dart';
import 'package:flutter_hydrated_login/repositorys/auth_repository.dart';
import 'package:flutter_hydrated_login/routes/app_pages.dart';
import 'package:flutter_hydrated_login/routes/app_routes.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'bloc/auth/auth_bloc.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  Bloc.observer = BlocWatcher();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository(),
          ),
        ],
        child: BlocProvider(
            create: (context) => AuthBloc(),
            child: BlocBuilder<AuthBloc, AuthState>(builder: (_, state) {
              return MaterialApp(
                theme: ThemeData.dark(),
                initialRoute: getRoute(state),
                routes: AppPages.routes(),
              );
            })));
  }

  String getRoute(AuthState state) {
    print(state.runtimeType);
    switch (state.runtimeType) {
      case AuthEmpty:
        return AppRoutes.LOGIN;
        break;
      case AuthUser:
        return AppRoutes.HOME;
        break;
      default:
        return AppRoutes.LOGIN;
    }
  }
}
