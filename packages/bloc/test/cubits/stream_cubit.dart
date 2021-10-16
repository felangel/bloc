import 'dart:async';

import 'package:bloc/bloc.dart';

class StreamCubit<T> extends Cubit<T> {
  StreamCubit({required T state, required Stream<T> stream})
      : _stream = stream,
        super(state);

  final Stream<T> _stream;

  void forEach() => emit.forEach<T>(_stream, onData: ((i) => i));

  void onEach() => emit.onEach<T>(_stream, onData: ((i) => emit(i)));
}
