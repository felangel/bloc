import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import './complex.dart';

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  ComplexState get initialState => ComplexStateA();

  @override
  Stream<ComplexState> transformEvents(
    Stream<ComplexEvent> events,
    Function(ComplexEvent) next,
  ) {
    return events.switchMap(next);
  }

  @override
  Stream<ComplexState> mapEventToState(ComplexEvent event) async* {
    if (event is ComplexEventA) {
      yield ComplexStateA();
    } else if (event is ComplexEventB) {
      yield ComplexStateB();
    } else if (event is ComplexEventC) {
      await Future<void>.delayed(Duration(milliseconds: 100));
      yield ComplexStateC();
    } else if (event is ComplexEventD) {
      await Future<void>.delayed(Duration(milliseconds: 100));
      yield ComplexStateD();
    }
  }

  @override
  Stream<ComplexState> transformStates(Stream<ComplexState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }
}
