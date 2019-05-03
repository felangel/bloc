import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

mixin EventProviderBloc<TInEvent, TOutEvent, TState> on Bloc<TInEvent, TState> {
  final StreamController<TOutEvent> _outEventSubject = StreamController<TOutEvent>.broadcast();
  Stream<TOutEvent> get event => _outEventSubject.stream;

  @protected
  @mustCallSuper
  void onEmitEvent(TOutEvent event) => null;

  @protected
  void emitEvent(TOutEvent event) {
    onEmitEvent(event);
    _outEventSubject.sink.add(event);
  }

  @override
  void dispose() {
    _outEventSubject.close();
    super.dispose();
  }
}
