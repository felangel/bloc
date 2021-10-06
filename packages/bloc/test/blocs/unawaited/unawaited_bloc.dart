import 'dart:async';

import 'package:bloc/bloc.dart';

class UnawaitedEvent {}

class UnawaitedState {}

class UnawaitedBloc extends Bloc<UnawaitedEvent, UnawaitedState> {
  UnawaitedBloc(Future<void> future) : super(UnawaitedState()) {
    on<UnawaitedEvent>((event, emit) {
      future.whenComplete(() => emit(UnawaitedState()));
    });
  }
}
