import 'package:flutter_todos/home/riverpod/home_state.dart';
import 'package:riverpod/riverpod.dart';

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void setTab(HomeTab tab) => state = state.copyWith(tab: tab);
}
