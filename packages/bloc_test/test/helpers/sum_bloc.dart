import 'dart:async';

import 'package:bloc/bloc.dart';

import 'helpers.dart';

class SumEvent {
  final int value;

  const SumEvent(this.value);
}

class SumBloc extends Bloc<SumEvent, int> {
  StreamSubscription<int> _countSubscription;

  SumBloc(CounterBloc counterBloc) : super(0) {
    _countSubscription = counterBloc.listen((count) => add(SumEvent(count)));
  }

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
