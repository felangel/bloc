import 'package:bloc/bloc.dart';

class FailingObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    throw StateError('catch me');
  }
}
