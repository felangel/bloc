import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => AppState.initial();

  @override
  Stream<AppState> transformEvents(
    Stream<AppEvent> events,
    Stream<AppState> Function(AppEvent event) next,
  ) {
    return super.transformEvents(events.distinct(), next);
  }

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is PageChanged) {
      yield state.copyWith(activePageIndex: event.newIndex);
    }
  }
}
