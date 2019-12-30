import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// {@template repositoryprovider}
/// Takes a `ValueBuilder` that is responsible for
/// creating the repository and a [child] which will have access to the repository via `RepositoryProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance of a repository can be provided
/// to multiple widgets within a subtree.
///
/// Lazily creates the provided repository unless [lazy] is set to `false`.
///
/// ```dart
/// RepositoryProvider(
///   create: (context) => RepositoryA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class RepositoryProvider<T> extends Provider<T> {
  /// {@macro repositoryprovider}
  RepositoryProvider({
    Key key,
    @required Create<T> create,
    Widget child,
    bool lazy,
  }) : super(
          key: key,
          create: create,
          dispose: (_, __) {},
          child: child,
          lazy: lazy,
        );

  /// Takes a repository and a [child] which will have access to the repository.
  /// A new repository should not be created in `RepositoryProvider.value`.
  /// Repositories should always be created using the default constructor within the [builder].
  RepositoryProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  /// Method that allows widgets to access a repository instance as long as their `BuildContext`
  /// contains a [RepositoryProvider] instance.
  static T of<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on dynamic catch (_) {
      throw FlutterError(
        """
        RepositoryProvider.of() called with a context that does not contain a repository of type $T.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<$T>().

        This can happen if:
        1. The context you used comes from a widget above the RepositoryProvider.
        2. You used MultiRepositoryProvider and didn\'t explicity provide the RepositoryProvider types.

        Good: RepositoryProvider<$T>(create: (context) => $T())
        Bad: RepositoryProvider(create: (context) => $T()).

        The context used was: $context
        """,
      );
    }
  }
}
