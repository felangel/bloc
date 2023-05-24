import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnExceptionBloc extends Bloc<CounterEvent, int> {
  OnExceptionBloc({
    required this.exception,
    required this.onErrorCallback,
  }) : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  final void Function(Object, StackTrace) onErrorCallback;
  final Exception exception;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  void _onCounterEvent(CounterEvent event, Emitter<int> emit) {
    throw exception;
  }
}
