import 'dart:async';

import 'package:bloc/bloc.dart';

abstract class ComplexEvent {}

class ComplexEventA extends ComplexEvent {}

class ComplexEventB extends ComplexEvent {}

abstract class ComplexState {}

class ComplexStateA extends ComplexState {}

class ComplexStateB extends ComplexState {}

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  ComplexBloc() : super(ComplexStateA());

  @override
  Stream<ComplexState> mapEventToState(
    ComplexEvent event,
  ) async* {
    if (event is ComplexEventA) {
      yield ComplexStateA();
    } else if (event is ComplexEventB) {
      yield ComplexStateB();
    }
  }
}
