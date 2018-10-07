import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class Bloc<T> {
  final _eventSubject = PublishSubject<dynamic>();
  Stream<T> _stateSubject;

  Stream<T> get state => _stateSubject;
  Sink<dynamic> get event => _eventSubject.sink;

  Bloc() {
    _stateSubject = _eventSubject.switchMap((event) {
      return mapEventToState(event);
    });
  }

  dispose() {
    _eventSubject.close();
  }

  Stream<T> mapEventToState(event);
}
