import 'package:flutter_web/widgets.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:bloc/bloc.dart';

class BlocProvider<T extends Bloc<dynamic, dynamic>> extends Provider<T> {
  /// Takes a [ValueBuilder] that is responsible for
  /// building the bloc and a child which will have access to the bloc via `BlocProvider.of(context)`.
  /// It is used as a dependency injection (DI) widget so that a single instance of a bloc can be provided
  /// to multiple widgets within a subtree.
  ///
  /// Automatically handles disposing the bloc when used with a `builder`.
  ///
  /// ```dart
  /// BlocProvider(
  ///   builder: (BuildContext context) => BlocA(),
  ///   child: ChildA(),
  /// );
  /// ```
  BlocProvider({
    Key key,
    @required ValueBuilder<T> builder,
    Widget child,
  }) : super(
          key: key,
          builder: builder,
          dispose: (_, bloc) => bloc?.dispose(),
          child: child,
        );

  /// Takes a `Bloc` and a child which will have access to the bloc via `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the bloc will not be automatically disposed.
  /// As a result, `BlocProvider.value` should mainly be used for providing existing blocs
  /// to new routes.
  ///
  /// A new bloc should not be created in `BlocProvider.value`.
  /// Blocs should always be created using the default constructor within the `builder`.
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
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  /// Method that allows widgets to access a bloc instance as long as their `BuildContext`
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
    } catch (_) {
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
}
