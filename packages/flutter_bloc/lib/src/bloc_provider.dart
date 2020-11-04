import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:inherited_stream/inherited_stream.dart';
import 'package:nested/nested.dart';

/// Function that creates a [Bloc] or [Cubit] of type [T].
typedef _Create<T extends Cubit<Object>> = T Function(BuildContext context);

/// Mixin which allows `MultiBlocProvider` to infer the types
/// of multiple [BlocProvider]s.
mixin BlocProviderSingleChildWidget on SingleChildWidget {}

/// {@template bloc_provider}
/// Takes a [create] function that is responsible for
/// creating the [Bloc] or [Cubit] and a [child] which will have access
/// to the instance via `BlocProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a [Bloc] or [Cubit] can be provided to multiple widgets within a subtree.
///
/// ```dart
/// BlocProvider(
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
///
/// It automatically handles closing the instance when used with [create].
/// By default, [create] is called only when the instance is accessed.
/// To override this behavior, set [lazy] to `false`.
///
/// ```dart
/// BlocProvider(
///   lazy: false,
///   create: (BuildContext context) => BlocA(),
///   child: ChildA(),
/// );
/// ```
///
/// {@endtemplate}
class BlocProvider<T extends Cubit<Object>> extends SingleChildStatefulWidget
    with BlocProviderSingleChildWidget {
  /// {@macro bloc_provider}
  const BlocProvider({
    Key key,
    @required this.create,
    this.child,
    this.lazy = true,
  })  : assert(create != null),
        super(key: key);

  /// Takes a [value] and a [child] which will have access to the [value] via
  /// `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the [Bloc] or [Cubit]
  /// will not be automatically closed.
  /// As a result, `BlocProvider.value` should only be used for providing
  /// existing instances to new subtrees.
  ///
  /// A new [Bloc] or [Cubit] should not be created in `BlocProvider.value`.
  /// New instances should always be created using the
  /// default constructor within the [create] function.
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
  }) : this(key: key, create: (_) => value, child: child);

  /// Creates a [Bloc] or [Cubit] of type [T].
  final _Create<T> create;

  /// Widget which will have access to the [Bloc] or [Cubit].
  final Widget child;

  /// Whether the [Bloc] or [Cubit] should be created lazily.
  /// Defaults to `true`.
  final bool lazy;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  /// Method that allows widgets to access a [Bloc] or [Cubit] instance
  /// as long as their `BuildContext` contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context);
  /// ```
  static T of<T extends Cubit<Object>>(
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
        BlocProvider.of() called with a context that does not contain a Bloc/Cubit of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
        ''',
      );
    }
    return provider.value();
  }
}

/// Extends the [BuildContext] class with the ability
/// to perform a lookup based on a [Bloc] or [Cubit] type.
extension BlocProviderExtension on BuildContext {
  /// Performs a lookup using the [BuildContext] to obtain
  /// the nearest ancestor [Cubit] of type [T].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// BlocProvider.of<T>(context);
  /// ```
  T bloc<T extends Cubit<Object>>() => BlocProvider.of<T>(this);
}

class _BlocProviderState<T extends Cubit<Object>>
    extends SingleChildState<BlocProvider<T>> {
  T _bloc;
  final _completer = Completer<T>();

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

class _InheritedBlocProvider<T extends Cubit<Object>>
    extends DeferredInheritedStream<T> {
  _InheritedBlocProvider({
    Key key,
    @required Future<T> deferredBloc,
    @required this.value,
    Widget child,
  }) : super(key: key, deferredStream: deferredBloc, child: child);

  final ValueGetter<T> value;
}
