part of 'app_bloc.dart';

enum Tab {
  offers,
  shopping,
  cart;

  static const initial = Tab.offers;
}

class AppState extends Equatable {
  const AppState({
    this.currentTab = Tab.initial,
  });

  final Tab currentTab;

  AppState copyWith({
    Tab? currentTab,
  }) {
    return AppState(
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [currentTab];
}
