part of 'app_bloc.dart';

enum AppTab {
  offers,
  shopping,
  cart;

  static const initial = AppTab.offers;
}

class AppState extends Equatable {
  const AppState({
    this.currentTab = AppTab.initial,
  });

  final AppTab currentTab;

  AppState copyWith({
    AppTab? currentTab,
  }) {
    return AppState(
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [currentTab];
}
