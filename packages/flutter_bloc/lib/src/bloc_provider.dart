import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';

/// A Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`.
/// It is used as a DI widget so that a single instance of a bloc can be provided
/// to multiple widgets within a subtree.
class BlocProvider<T extends Bloc<dynamic, dynamic>> extends InheritedWidget {
  /// The [Bloc] which is to be made available throughout the subtree
  final T bloc;

  /// The [Widget] and its descendants which will have access to the [Bloc].
  final Widget child;

  BlocProvider({
    Key key,
    @required this.bloc,
    @required this.child,
  })  : assert(bloc != null),
        assert(child != null),
        super(key: key);

  /// Method that allows widgets to access the bloc as long as their `BuildContext`
  /// contains a `BlocProvider` instance.
  static T of<T extends Bloc<dynamic, dynamic>>(BuildContext context) {
    final type = _typeOf<BlocProvider<T>>();
    final BlocProvider<T> provider =
        context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;

    if (provider == null) {
      throw FlutterError(
          'BlocProvider.of() called with a context that does not contain a Bloc of type $T.\n'
          'No ancestor could be found starting from the context that was passed '
          'to BlocProvider.of<$T>(). This can happen '
          'if the context you use comes from a widget above the BlocProvider.\n'
          'The context used was:\n'
          '  $context');
    }
    return provider?.bloc;
  }

  /// Necessary to obtain generic [Type]
  /// https://github.com/dart-lang/sdk/issues/11923
  static Type _typeOf<T>() => T;

  @override
  bool updateShouldNotify(BlocProvider oldWidget) => false;
}
