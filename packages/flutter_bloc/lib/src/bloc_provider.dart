import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:bloc/bloc.dart';

/// {@template blocprovider}
/// Takes a [ValueBuilder] that is responsible for
/// building the [bloc] and a [child] which will have access to the [bloc] via `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance of a [bloc] can be provided
/// to multiple widgets within a subtree.
///
/// Automatically handles closing the [bloc] when used with a [builder].
///
/// ```dart
/// BlocProvider(
///   builder: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class BlocProvider<T extends Bloc<dynamic, dynamic>>
    extends ValueDelegateWidget<T> implements SingleChildCloneableWidget {
  /// [child] and its descendants which will have access to the [bloc].
  final Widget child;

  /// {@macro blocprovider}
  BlocProvider({
    Key key,
    ValueBuilder<T> builder,
    Widget child,
  }) : this._(
          key: key,
          delegate: BuilderStateDelegate<T>(
            builder,
            dispose: (_, bloc) => bloc?.close(),
          ),
          child: child,
        );

  /// Takes a [bloc] and a [child] which will have access to the [bloc] via `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the [bloc] will not be automatically closed.
  /// As a result, `BlocProvider.value` should mainly be used for providing existing [bloc]s
  /// to new routes.
  ///
  /// A new [bloc] should not be created in `BlocProvider.value`.
  /// [bloc]s should always be created using the default constructor within the [builder].
  ///
  /// ```dart
  /// BlocProvider.value(
  ///   value: BlocProvider.of<BlocA>(context),
  ///   child: ScreenA(),
  /// );
  BlocProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : this._(
          key: key,
          delegate: SingleValueDelegate<T>(value),
          child: child,
        );

  /// Internal constructor responsible for creating the [BlocProvider].
  /// Used by the [BlocProvider] default and value constructors.
  BlocProvider._({
    Key key,
    @required ValueStateDelegate<T> delegate,
    this.child,
  }) : super(key: key, delegate: delegate);

  /// Method that allows widgets to access a [bloc] instance as long as their `BuildContext`
  /// contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up in the widget tree
  /// we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context)
  /// ```
  static T of<T extends Bloc<dynamic, dynamic>>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on Object catch (_) {
      throw FlutterError(
        """
        BlocProvider.of() called with a context that does not contain a Bloc of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if:
        1. The context you used comes from a widget above the BlocProvider.
        2. You used MultiBlocProvider and didn\'t explicity provide the BlocProvider types.

        Good: BlocProvider<$T>(builder: (context) => $T())
        Bad: BlocProvider(builder: (context) => $T()).

        The context used was: $context
        """,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InheritedProvider<T>(
      value: delegate.value,
      child: child,
    );
  }

  @override
  BlocProvider<T> cloneWithChild(Widget child) {
    return BlocProvider<T>._(
      key: key,
      delegate: delegate,
      child: child,
    );
  }
}
