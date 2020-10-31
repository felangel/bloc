import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:inherited_stream/inherited_stream.dart';
import 'package:nested/nested.dart';

/// A function that creates a [Cubit] of type [T].
typedef CreateBloc<T extends Cubit<dynamic>> = T Function(BuildContext context);

/// Mixin which allows `MultiBlocProvider` to infer the types
/// of multiple [BlocProvider]s.
mixin BlocProviderSingleChildWidget on SingleChildWidget {}

/// Extends the [BuildContext] class with the ability
/// to perform a lookup based on a [Cubit] type.
extension BlocProviderExtension on BuildContext {
  /// Performs a lookup using the [BuildContext] to obtain
  /// the nearest ancestor [Cubit] of type [C].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// BlocProvider.of<C>(context);
  /// ```
  C bloc<C extends Cubit<Object>>() => BlocProvider.of<C>(this);
}

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
class BlocProvider<B extends Cubit<dynamic>> extends SingleChildStatefulWidget
    with BlocProviderSingleChildWidget {
  /// {@macro bloc_provider}
  const BlocProvider({
    Key key,
    @required this.create,
    this.child,
    this.lazy = true,
  })  : assert(create != null),
        super(key: key);

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
    @required B value,
    Widget child,
  }) : this(key: key, create: (_) => value, child: child);

  /// Creates a [Cubit] of type [B].
  final CreateBloc<B> create;

  /// Widget which will have access to the [Cubit].
  final Widget child;

  /// Whether the [Cubit] should be created lazily.
  /// Defaults to `true`.
  final bool lazy;

  @override
  _BlocProviderState<B> createState() => _BlocProviderState<B>();

  /// Method that allows widgets to access a `cubit` instance as long as their
  /// `BuildContext` contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context);
  /// ```
  static T of<T extends Cubit<dynamic>>(
    BuildContext context, {
    bool listen = false,
  }) {
    final provider = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_InheritedBlocProvider<T>>()
        : context
            .getElementForInheritedWidgetOfExactType<
                _InheritedBlocProvider<T>>()
            ?.widget as _InheritedBlocProvider<T>;
    if (provider == null) {
      throw FlutterError(
        '''
        BlocProvider.of() called with a context that does not contain a Cubit of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
        ''',
      );
    }
    return provider.value();
  }
}

class _BlocProviderState<B extends Cubit<dynamic>>
    extends SingleChildState<BlocProvider<B>> {
  B _bloc;
  final _completer = Completer<B>();

  @override
  void initState() {
    super.initState();
    if (!widget.lazy) {
      _bloc = widget.create(context);
      _completer.complete(_bloc);
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return _InheritedBlocProvider(
      child: child ?? widget.child,
      deferredBloc: _completer.future,
      value: () {
        if (!_completer.isCompleted) {
          _bloc = widget.create(context);
          _completer.complete(_bloc);
        }
        return _bloc;
      },
    );
  }
}

class _InheritedBlocProvider<B extends Cubit<dynamic>>
    extends DeferredInheritedStream<B> {
  _InheritedBlocProvider({
    Key key,
    @required Future<B> deferredBloc,
    @required this.value,
    Widget child,
  }) : super(key: key, deferredStream: deferredBloc, child: child);

  final ValueGetter<B> value;
}
