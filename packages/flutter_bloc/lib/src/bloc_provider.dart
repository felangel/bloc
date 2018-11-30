import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';

/// A Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`.
/// It is used as a DI widget so that a single instance of a bloc can be provided
/// to multiple widgets within a subtree.
class BlocProvider<T extends Bloc<dynamic, dynamic>> extends StatelessWidget {
  /// The Bloc which is to be made available throughout the subtree
  final T bloc;

  /// The Widget and its descendants which will have access to the Bloc.
  final Widget child;

  BlocProvider({
    Key key,
    @required this.bloc,
    @required this.child,
  })  : assert(bloc != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => child;

  /// Method that allows widgets to access the bloc as long as their `BuildContext`
  /// contains a `BlocProvider` instance.
  static T of<T extends Bloc<dynamic, dynamic>>(BuildContext context) {
    BlocProvider<T> provider =
        context.ancestorWidgetOfExactType(_typeOf<BlocProvider<T>>());
    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}
