import 'package:analytics_repository/analytics_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppTabPressed>(_onTabPressed);
  }

  void _onTabPressed(AppTabPressed event, Emitter<AppState> emit) {
    emit(
      state.copyWith(
        currentTab: event.tab,
      ),
    );
  }
}
