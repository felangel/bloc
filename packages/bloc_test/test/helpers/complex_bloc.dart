import 'dart:async';

import 'package:bloc/bloc.dart';

abstract class ComplexEvent {}

class ComplexEventA extends ComplexEvent {
  ComplexEventA([this.id = 0]);
  final int id;
}

class ComplexEventB extends ComplexEvent {}

abstract class ComplexState {
  ComplexState([this.id = 0]);
  final int id;
}

class ComplexStateA extends ComplexState {
  ComplexStateA([int id = 0]) : super(id);
}

class ComplexStateB extends ComplexState {}

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  @override
  ComplexState get initialState => ComplexStateA();

  @override
  Stream<ComplexState> mapEventToState(
    ComplexEvent event,
  ) async* {
    if (event is ComplexEventA) {
      yield ComplexStateA(event.id);
    } else if (event is ComplexEventB) {
      yield ComplexStateB();
    }
  }
}
