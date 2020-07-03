import 'package:flutter/widgets.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:provider/provider.dart';
import 'package:bloc/bloc.dart';

/// {@template bloc_provider}
/// Takes a [ValueBuilder] that is responsible for creating the [bloc] and
/// a [child] which will have access to the [bloc] via
/// `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [bloc] can be provided to multiple widgets within a subtree.
///
/// Automatically handles closing the [bloc] when used with [create] and lazily
/// creates the provided [bloc] unless [lazy] is set to `false`.
///
/// ```dart
/// BlocProvider(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class BlocProvider<T extends Bloc<Object, Object>> extends CubitProvider<T> {
  /// {@macro bloc_provider}
  BlocProvider({
    Key key,
    @required Create<T> create,
    Widget child,
    bool lazy,
  }) : super(
          key: key,
          create: create,
          child: child,
          lazy: lazy,
        );

  /// Takes a [bloc] and a [child] which will have access to the [bloc] via
  /// `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the [bloc] will not be automatically
  /// closed.
  /// As a result, `BlocProvider.value` should mainly be used for providing
  /// existing [bloc]s to new routes.
  ///
  /// A new [bloc] should not be created in `BlocProvider.value`.
  /// [bloc]s should always be created using the default constructor within
  /// [create].
  ///
  /// ```dart
  /// BlocProvider.value(
  ///   value: BlocProvider.of<BlocA>(context),
  ///   child: ScreenA(),
  /// );
  /// ```
  BlocProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  /// Method that allows widgets to access a [bloc] instance as long as their
  /// `BuildContext` contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context)
  /// ```
  static T of<T extends Bloc<dynamic, dynamic>>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        """
        BlocProvider.of() called with a context that does not contain a Bloc of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
        """,
      );
    }
  }
}

/// Extends the `BuildContext` class with the ability
/// to perform a lookup based on a `Bloc` type.
extension BlocProviderExtension on BuildContext {
  /// Performs a lookup using the `BuildContext` to obtain
  /// the nearest ancestor `Bloc` of type [B].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// BlocProvider.of<B>(context)
  /// ```
  B bloc<B extends Bloc<Object, Object>>() => BlocProvider.of<B>(this);
}
