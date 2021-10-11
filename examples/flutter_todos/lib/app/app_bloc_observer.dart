// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
