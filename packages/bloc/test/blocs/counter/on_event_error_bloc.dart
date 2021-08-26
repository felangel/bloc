import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnEventErrorBloc extends Bloc<CounterEvent, int> {
  OnEventErrorBloc({required this.exception}) : super(0) {
    on<CounterEvent>((_, __) {});
  }

  final Exception exception;

  @override
  // ignore: must_call_super
  void onEvent(CounterEvent event) {
    throw exception;
  }
}
