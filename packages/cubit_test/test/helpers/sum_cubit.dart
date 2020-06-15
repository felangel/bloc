import 'dart:async';

import 'package:cubit/cubit.dart';

import 'helpers.dart';

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
