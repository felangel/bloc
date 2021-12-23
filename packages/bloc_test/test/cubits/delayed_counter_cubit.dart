import 'package:bloc/bloc.dart';

class DelayedCounterCubit extends Cubit<int> {
  DelayedCounterCubit() : super(0);

  void increment() {
    Future<void>.delayed(
      const Duration(milliseconds: 300),
      () {
        if (!isClosed) emit(state + 1);
      },
    );
  }
}
