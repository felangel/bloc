import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/src/repository_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// {@template multi_repository_provider}
/// Merges multiple [RepositoryProvider] widgets into one widget tree.
///
/// [MultiRepositoryProvider] improves the readability and eliminates the need
/// to nest multiple [RepositoryProvider]s.
///
/// By using [MultiRepositoryProvider] we can go from:
///
/// ```dart
/// RepositoryProvider<RepositoryA>(
///   create: (context) => RepositoryA(),
///   child: RepositoryProvider<RepositoryB>(
///     create: (context) => RepositoryB(),
///     child: RepositoryProvider<RepositoryC>(
///       create: (context) => RepositoryC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiRepositoryProvider(
///   providers: [
///     RepositoryProvider<RepositoryA>(create: (context) => RepositoryA()),
///     RepositoryProvider<RepositoryB>(create: (context) => RepositoryB()),
///     RepositoryProvider<RepositoryC>(create: (context) => RepositoryC()),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiRepositoryProvider] converts the [RepositoryProvider] list into a tree
/// of nested [RepositoryProvider] widgets.
/// As a result, the only advantage of using [MultiRepositoryProvider] is
/// improved readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiRepositoryProvider extends MultiProvider {
  /// {@macro multi_repository_provider}
  MultiRepositoryProvider({
    required List<SingleChildWidget> providers,
    required Widget child,
    Key? key,
  }) : super(key: key, providers: providers, child: child);
}
