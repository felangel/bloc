import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';

part 'complex_event.dart';
part 'complex_state.dart';

class ComplexBloc extends Bloc<ComplexEvent, ComplexState> {
  ComplexBloc() : super(ComplexStateA());

  @override
  Stream<Transition<ComplexEvent, ComplexState>> transformEvents(
    Stream<ComplexEvent> events,
    // ignore: deprecated_member_use_from_same_package
    TransitionFunction<ComplexEvent, ComplexState> transitionFn,
  ) {
    return events.switchMap(transitionFn);
  }

  @override
  Stream<ComplexState> mapEventToState(ComplexEvent event) async* {
    if (event is ComplexEventA) {
      yield ComplexStateA();
    } else if (event is ComplexEventB) {
      yield ComplexStateB();
    } else if (event is ComplexEventC) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield ComplexStateC();
    } else if (event is ComplexEventD) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield ComplexStateD();
    }
  }

  @override
  Stream<Transition<ComplexEvent, ComplexState>> transformTransitions(
    Stream<Transition<ComplexEvent, ComplexState>> transitions,
  ) {
    return transitions.debounce(const Duration(milliseconds: 50));
  }
}
