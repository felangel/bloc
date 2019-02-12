import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnErrorBloc extends Bloc<CounterEvent, int> {
  OnErrorBloc(this.exception, this.testOnError);

  final Function testOnError;
  final Exception exception;

  @override
  int get initialState => 0;

  @override
  void onError(Object error, StackTrace stacktrace) {
    testOnError(error, stacktrace);
  }

  @override
  Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
    throw exception;
  }
}
