import 'dart:async';

import 'package:bloc/bloc.dart';

import 'helpers.dart';

class SumEvent {
  final int value;

  const SumEvent(this.value);
}

class SumBloc extends Bloc<SumEvent, int> {
  StreamSubscription<int> _countSubscription;

  SumBloc(CounterBloc counterBloc) {
    _countSubscription = counterBloc.listen((count) => add(SumEvent(count)));
  }

  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(
    SumEvent event,
  ) async* {
    yield state + event.value;
  }

  @override
  Future<void> close() {
    _countSubscription.cancel();
    return super.close();
  }
}
