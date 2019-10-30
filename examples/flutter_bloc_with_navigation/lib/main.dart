import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/app_bloc_delegate.dart';
import 'package:flutter_bloc_with_navigation/shared/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  BlocSupervisor.delegate = AppBlocDelegate();
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(builder: (_) => AppBloc()),
        // Some other global blocs...
      ],
      child: MaterialApp(
        home: const MainPage(),
      ),
    );
  }
}
