import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
  }

  @override
  void onTransition(Transition transition) {
    print(transition);
  }
}
