import 'dart:async';

import 'package:cubit/cubit.dart';

class AsyncCounterCubit extends Cubit<int> {
  AsyncCounterCubit() : super(0);

  Future<void> increment() async {
    await Future<void>.delayed(const Duration(microseconds: 1));
    emit(state + 1);
  }
}
