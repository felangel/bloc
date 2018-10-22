import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';

/// A Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`.
/// It is used as a DI widget so that a single instance of a bloc can be provided
/// to multiple widgets within a subtree.
class BlocProvider extends InheritedWidget {
  /// The Bloc which is to be made available throughout the subtree
  final Bloc bloc;

  BlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  })  : assert(bloc != null),
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(BlocProvider oldWidget) => oldWidget.bloc != bloc;

  /// Method that allows widgets to access the bloc as long as their `BuildContext`
  /// contains a `BlocProvider` instance.
  static Bloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider).bloc;
}
