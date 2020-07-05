import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Mixin which allows `MultiRepositoryProvider` to infer the types
/// of multiple [RepositoryProvider]s.
mixin RepositoryProviderSingleChildWidget on SingleChildWidget {}

/// {@template repository_provider}
/// Takes a `ValueBuilder` that is responsible for creating the repository and
/// a [child] which will have access to the repository via
/// `RepositoryProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a repository can be provided to multiple widgets within a subtree.
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
class RepositoryProvider<T> extends Provider<T>
    with RepositoryProviderSingleChildWidget {
  /// {@macro repository_provider}
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
  /// Repositories should always be created using the default constructor
  /// within the [builder].
  RepositoryProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  /// Method that allows widgets to access a repository instance as long as
  /// their `BuildContext` contains a [RepositoryProvider] instance.
  static T of<T>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on ProviderNotFoundException catch (_) {
      throw FlutterError(
        """
        RepositoryProvider.of() called with a context that does not contain a repository of type $T.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<$T>().

        This can happen if the context you used comes from a widget above the RepositoryProvider.

        The context used was: $context
        """,
      );
    }
  }
}

/// Extends the `BuildContext` class with the ability
/// to perform a lookup based on a repository type.
extension RepositoryProviderExtension on BuildContext {
  /// Performs a lookup using the `BuildContext` to obtain
  /// the nearest ancestor repository of type [T].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// RepositoryProvider.of<T>(context)
  /// ```
  T repository<T>() => RepositoryProvider.of<T>(this);
}
