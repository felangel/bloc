import 'dart:async';

import 'package:bloc/bloc.dart';

import 'counter_cubit.dart';

class SumCubit extends Cubit<int> {
  SumCubit(CounterCubit counterCubit) : super(0) {
    _countSubscription = counterCubit.listen(
      (count) => emit(state + count),
    );
  }

  StreamSubscription<int> _countSubscription;

  @override
  Future<void> close() {
    _countSubscription.cancel();
    return super.close();
  }
}
