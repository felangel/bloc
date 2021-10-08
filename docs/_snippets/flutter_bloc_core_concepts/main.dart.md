```dart
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shopping_cart/app.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';

void main() {
  runApp(App(shoppingRepository: ShoppingRepository()));
}
```