part of 'app_bloc.dart';

enum Tab {
  offers,
  shopping,
  cart;

  static const initial = Tab.offers;

  Analytic get routeAnalytic {
    String eventName;

    switch (this) {
      case Tab.offers:
        eventName = 'offers_tab_viewed';
        break;
      case Tab.shopping:
        eventName = 'shopping_tab_viewed';
        break;
      case Tab.cart:
        eventName = 'cart_tab_viewed';
        break;
    }
    return RouteAnalytic(eventName);
  }
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
