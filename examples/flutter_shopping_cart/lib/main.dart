import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shopping_cart/app.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_shopping_cart/simple_bloc_observer.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(App(shoppingRepository: ShoppingRepository())),
    blocObserver: SimpleBlocObserver(),
  );
}
