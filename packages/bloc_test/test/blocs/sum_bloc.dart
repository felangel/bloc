import 'dart:async';

import 'package:bloc/bloc.dart';

import 'counter_bloc.dart';

class SumEvent {
  const SumEvent(this.value);

  final int value;
}

class SumBloc extends Bloc<SumEvent, int> {
  SumBloc(CounterBloc counterBloc) : super(0) {
    on<SumEvent>((event, emit) => emit(state + event.value));

    _countSubscription = counterBloc.stream.listen(
      (count) => add(SumEvent(count)),
    );
  }

  late StreamSubscription<int> _countSubscription;

  @override
  Future<void> close() {
    _countSubscription.cancel();
    return super.close();
  }
}
