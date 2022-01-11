import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '<rename_file>_event.dart';
part '<rename_file>_state.dart';

class <rename>Bloc extends Bloc<<rename>Event, <rename>State> {
  <rename>Bloc() : super(<rename>State.initial()) {
    on<<rename>Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
