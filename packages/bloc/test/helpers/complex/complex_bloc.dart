import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import './complex.dart';

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  ComplexState get initialState => ComplexStateA();

  @override
  Stream<ComplexEvent> transform(Stream<ComplexEvent> events) {
    return events.distinct();
  }

  @override
  Stream<ComplexState> mapEventToState(ComplexEvent event) {
    if (event is ComplexEventA) {
      return Observable.just(ComplexStateA());
    }
    if (event is ComplexEventB) {
      return Observable.just(ComplexStateB());
    }
    return Observable.just(ComplexStateC());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexBloc &&
          runtimeType == other.runtimeType &&
          initialState == other.initialState;

  @override
  int get hashCode =>
      initialState.hashCode ^ mapEventToState.hashCode ^ transform.hashCode;
}
