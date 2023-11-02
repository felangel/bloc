import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// {@template repository_provider}
/// Takes a [Create] function that is responsible for creating the repository
/// and a `child` which will have access to the repository via
/// `RepositoryProvider.of(context)`.
/// It is used as a dependency injection (DI) widget so that a single instance
/// of a repository can be provided to multiple widgets within a subtree.
///
/// ```dart
/// RepositoryProvider(
///   create: (context) => RepositoryA(),
///   child: ChildA(),
/// );
/// ```
///
/// Lazily creates the repository unless `lazy` is set to `false`.
///
/// ```dart
/// RepositoryProvider(
///   lazy: false,`
///   create: (context) => RepositoryA(),
///   child: ChildA(),
/// );
/// ```
/// {@endtemplate}
class RepositoryProvider<T> extends Provider<T> {
  /// {@macro repository_provider}
  RepositoryProvider({
    required Create<T> create,
    Key? key,
    Widget? child,
    bool? lazy,
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
  /// within the [Create] function.
  RepositoryProvider.value({
    required T value,
    Key? key,
    Widget? child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  /// Method that allows widgets to access a repository instance as long as
  /// their `BuildContext` contains a [RepositoryProvider] instance.
  static T of<T>(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        RepositoryProvider.of() called with a context that does not contain a repository of type $T.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<$T>().

        This can happen if the context you used comes from a widget above the RepositoryProvider.

        The context used was: $context
        ''',
      );
    }
  }
}
