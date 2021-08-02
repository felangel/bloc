import 'dart:async';

import 'package:bloc/bloc.dart';

abstract class StreamEvent {}

class Subscribe extends StreamEvent {}

class OnData extends StreamEvent {
  OnData(this.data);
  final int data;
}

class StreamBloc extends Bloc<StreamEvent, int> {
  StreamBloc(Stream<int> stream) : super(0) {
    on<StreamEvent>((_, emit) {
      _subscription?.cancel();
      _subscription = stream.listen((i) {
        Future<void>.delayed(
          const Duration(milliseconds: 100),
          () => add(OnData(i)),
        );
      });
    });

    on<OnData>((event, emit) => emit(event.data));
  }

  StreamSubscription<int>? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
