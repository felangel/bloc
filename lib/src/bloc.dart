import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class Bloc<E, S> {
  final _eventSubject = PublishSubject<E>();
  Stream<S> _stateSubject;

  Stream<S> get state => _stateSubject;
  S get initialState => null;

  Bloc() {
    _stateSubject = (transform(_eventSubject) as Observable<E>)
        .switchMap((E event) => mapEventToState(event));
  }

  dispatch(E event) {
    _eventSubject.sink.add(event);
  }

  Stream<E> transform(Stream<E> events) => events;

  dispose() {
    _eventSubject.close();
  }

  Stream<S> mapEventToState(E event);
}
