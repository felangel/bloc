import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/src/bloc_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// {@template multi_bloc_provider}
/// Merges multiple [BlocProvider] widgets into one widget tree.
///
/// [MultiBlocProvider] improves the readability and eliminates the need
/// to nest multiple [BlocProvider]s.
///
/// By using [MultiBlocProvider] we can go from:
///
/// ```dart
/// BlocProvider<BlocA>(
///   create: (BuildContext context) => BlocA(),
///   child: BlocProvider<BlocB>(
///     create: (BuildContext context) => BlocB(),
///     child: BlocProvider<BlocC>(
///       create: (BuildContext context) => BlocC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiBlocProvider(
///   providers: [
///     BlocProvider<BlocA>(
///       create: (BuildContext context) => BlocA(),
///     ),
///     BlocProvider<BlocB>(
///       create: (BuildContext context) => BlocB(),
///     ),
///     BlocProvider<BlocC>(
///       create: (BuildContext context) => BlocC(),
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiBlocProvider] converts the [BlocProvider] list into a tree of nested
/// [BlocProvider] widgets.
/// As a result, the only advantage of using [MultiBlocProvider] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiBlocProvider extends MultiProvider {
  /// {@macro multi_bloc_provider}
  MultiBlocProvider({
    required List<SingleChildWidget> providers,
    required Widget child,
    Key? key,
  }) : super(key: key, providers: providers, child: child);
}
