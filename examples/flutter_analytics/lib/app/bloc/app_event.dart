part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
}

class AppTabPressed extends AppEvent with Analytic {
  const AppTabPressed(this.tab);

  final AppTab tab;

  @override
  String get eventName {
    switch (tab) {
      case AppTab.offers:
        return 'offers_tab_pressed';
      case AppTab.shopping:
        return 'shopping_tab_pressed';
      case AppTab.cart:
        return 'cart_tab_pressed';
    }
  }

  @override
  List<Object> get props => [tab];
}
