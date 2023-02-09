import 'package:bloc/bloc.dart';
import 'package:ngdart/angular.dart';

import 'package:angular_counter/app_component.template.dart' as ng;

class SimpleBlocObserver extends BlocObserver {
  const SimpleBlocObserver();

  @override
  void onEvent(Bloc bloc, Object? event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  Bloc.observer = const SimpleBlocObserver();
  runApp(ng.AppComponentNgFactory);
}
