part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppTabPressed extends AppEvent with Analytic {
  const AppTabPressed(this.tab);

  final Tab tab;

  @override
  String get eventName {
    switch (tab) {
      case Tab.offers:
        return 'offers_tab_pressed';
      case Tab.shopping:
        return 'shopping_tab_pressed';
      case Tab.cart:
        return 'cart_tab_pressed';
    }
  }

  @override
  List<Object> get props => [tab];
}
