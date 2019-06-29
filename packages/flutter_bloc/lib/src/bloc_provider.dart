import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:bloc/bloc.dart';

/// A Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`.
/// It is used as a DI widget so that a single instance of a bloc can be provided
/// to multiple widgets within a subtree.
class BlocProvider<T extends Bloc<dynamic, dynamic>> extends Provider<T> {
  /// Default constructor which takes a `ValueBuilder` that is responsible for
  /// building the bloc and a child which will have access to the bloc.
  ///
  /// When the default constructor is used, `BlocProvider` will automatically
  /// handle disposing the bloc.
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

  /// Custom constructor which takes a `Bloc` and a child which will have access to the bloc.
  /// When `BlocProvider.value` is used, the bloc will not be automatically disposed.
  /// As a result, `BlocProvider.value` should mainly be used for providing existing blocs
  /// to new routes.
  ///
  /// A new bloc should not be created in `BlocProvider.value`.
  /// Blocs should always be created using the default constructor within the `builder`.
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
  /// contains a `BlocProvider` instance.
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
        2. You used BlocProviderTree and didn\'t explicity provide the BlocProvider types.

        Good: BlocProvider<$T>(builder: (context) => $T())
        Bad: BlocProvider(builder: (context) => $T()).

        The context used was: $context
        """,
      );
    }
  }
}
