import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// A function that creates a `Bloc` of type [T].
typedef CreateBloc<T extends Cubit<dynamic>> = T Function(
  BuildContext context,
);

/// Mixin which allows `MultiBlocProvider` to infer the types
/// of multiple [BlocProvider]s.
mixin BlocProviderSingleChildWidget on SingleChildWidget {}

/// {@template bloc_provider}
/// Takes a `ValueBuilder` that is responsible for creating the `bloc` and
/// a [child] which will have access to the `bloc` via
/// `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a `bloc` can be provided to multiple widgets within a subtree.
///
/// Automatically handles closing the `bloc` when used with `create` and lazily
/// creates the provided `bloc` unless [lazy] is set to `false`.
///
/// ```dart
/// BlocProvider(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class BlocProvider<T extends Cubit<Object>> extends SingleChildStatelessWidget
    with BlocProviderSingleChildWidget {
  /// {@macro bloc_provider}
  BlocProvider({
    Key key,
    @required CreateBloc<T> create,
    Widget child,
    bool lazy,
  }) : this._(
          key: key,
          create: create,
          dispose: (_, bloc) => bloc?.close(),
          child: child,
          lazy: lazy,
        );

  /// Takes a `bloc` and a [child] which will have access to the `bloc` via
  /// `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the `bloc` will not be automatically
  /// closed.
  /// As a result, `BlocProvider.value` should mainly be used for providing
  /// existing `bloc`s to new routes.
  ///
  /// A new `bloc` should not be created in `BlocProvider.value`.
  /// `bloc`s should always be created using the default constructor within
  /// `create`.
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
  }) : this._(
          key: key,
          create: (_) => value,
          child: child,
        );

  /// Internal constructor responsible for creating the [BlocProvider].
  /// Used by the [BlocProvider] default and value constructors.
  BlocProvider._({
    Key key,
    @required Create<T> create,
    Dispose<T> dispose,
    this.child,
    this.lazy,
  })  : _create = create,
        _dispose = dispose,
        super(key: key, child: child);

  /// [child] and its descendants which will have access to the `bloc`.
  final Widget child;

  /// Whether or not the `bloc` being provided should be lazily created.
  /// Defaults to `true`.
  final bool lazy;

  final Dispose<T> _dispose;

  final Create<T> _create;

  /// Method that allows widgets to access a `cubit` instance as long as their
  /// `BuildContext` contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context)
  /// ```
  static T of<T extends Cubit<Object>>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        BlocProvider.of() called with a context that does not contain a Cubit of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return InheritedProvider<T>(
      create: _create,
      dispose: _dispose,
      child: child,
      lazy: lazy,
    );
  }
}

/// Extends the `BuildContext` class with the ability
/// to perform a lookup based on a `Bloc` type.
extension BlocProviderExtension on BuildContext {
  /// Performs a lookup using the `BuildContext` to obtain
  /// the nearest ancestor `Cubit` of type [C].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// BlocProvider.of<C>(context)
  /// ```
  C bloc<C extends Cubit<Object>>() => BlocProvider.of<C>(this);
}
