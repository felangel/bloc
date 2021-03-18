import 'dart:async';

import 'package:bloc/bloc.dart';

import 'counter_bloc.dart';

class SumEvent {
  const SumEvent(this.value);

  final int value;
}

class SumBloc extends Bloc<SumEvent, int> {
  SumBloc(CounterBloc counterBloc) : super(0) {
    _countSubscription = counterBloc.stream.listen(
      (count) => add(SumEvent(count)),
    );
  }

  late StreamSubscription<int> _countSubscription;

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
