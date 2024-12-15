import 'dart:async';

import 'package:bloc/bloc.dart';

class StreamCubit extends Cubit<int> {
  StreamCubit() : super(0);

  Future<void> forEach(Stream<int> input) {
    return emit.forEach<int>(input, onData: (i) => i);
  }

  Future<void> onEach(Stream<int> input) {
    return emit.onEach<int>(input, onData: (i) => emit(i));
  }
}
