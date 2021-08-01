import 'dart:async';

import 'package:bloc/bloc.dart';

class StreamEvent {}

class StreamBloc extends Bloc<StreamEvent, int> {
  StreamBloc(Stream<int> stream) : super(0) {
    on<StreamEvent>((_, emit) {
      return emit.forEach<int>(
        stream,
        (i) => Future<int>.delayed(const Duration(milliseconds: 100), () => i),
      );
    }, restartable());
  }
}
