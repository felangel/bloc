import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:bloc/bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._analyticsRepository);

  final AnalyticsRepository _analyticsRepository;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is Analytic) _analyticsRepository.send(event);
  }
}
