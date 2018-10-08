import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class Bloc<T> {
  final _eventSubject = PublishSubject<dynamic>();
  Stream<T> _stateSubject;

  Stream<T> get state => _stateSubject;

  dispatch(dynamic event) {
    _eventSubject.sink.add(event);
  }

  Bloc() {
    _stateSubject = _eventSubject.switchMap((event) {
      return mapEventToState(event);
    });
  }

  dispose() {
    _eventSubject.close();
  }

  T get initialState => null;

  Stream<T> mapEventToState(event);
}
