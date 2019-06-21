import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'copyable.dart';

/// Signature for the builder function which takes the [BuildContext]
/// and is responsible for returning a [Bloc] which is to be provided to the subtree.
typedef BlocProviderBuilder<T extends Bloc<dynamic, dynamic>> = T Function(
  BuildContext context,
);

/// A Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`.
/// It is used as a DI widget so that a single instance of a bloc can be provided
/// to multiple widgets within a subtree.
///
/// By default, `BlocProvider` automatically disposes the provided bloc when the `BlocProvider`
/// widget is disposed. In a few edge cases, such as when using `BlocProvider` to provide an
/// existing bloc to another route, it might be necessary to prevent automatic disposal of the bloc.
/// In those cases, the `dispose` property can be set to `false`.
class BlocProvider<T extends Bloc<dynamic, dynamic>> extends StatefulWidget
    with Copyable {
  /// The [BlocProviderBuilder] which creates the [Bloc]
  /// that will be made available throughout the subtree.
  final BlocProviderBuilder<T> builder;

  /// The [Widget] and its descendants which will have access to the [Bloc].
  final Widget child;

  /// A `bool` which determines whether or not the [Bloc] should be automatically disposed
  /// by [BlocProvider].
  ///
  /// The default value is `true` and it should only be set to `false` in very few cases
  /// (such as where the multiple `BlocProviders` are used to provide the same [Bloc] across different routes).
  final bool dispose;

  BlocProvider({
    Key key,
    @required this.builder,
    this.child,
    this.dispose = true,
  })  : assert(builder != null),
        super(key: key);

  @override
  State<BlocProvider<T>> createState() => _BlocProviderState<T>();

  /// Method that allows widgets to access the bloc as long as their `BuildContext`
  /// contains a `BlocProvider` instance.
  static T of<T extends Bloc<dynamic, dynamic>>(BuildContext context) {
    try {
      return ImmutableProvider.of<T>(context);
    } on FlutterError catch (_) {
      throw FlutterError(
        """
        BlocProvider.of() called with a context that does not contain a Bloc of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().
        This can happen if the context you use comes from a widget above the BlocProvider.
        This can also happen if you used BlocProviderTree and didn\'t explicity provide 
        the BlocProvider types: BlocProvider(bloc: $T()) instead of BlocProvider<$T>(bloc: $T()).
        The context used was: $context
        """,
      );
    }
  }

  /// Clones the current [BlocProvider] with a new child [Widget].
  /// All other values, including [Key] and [Bloc] are preserved.
  @override
  BlocProvider<T> copyWith(Widget child) {
    return BlocProvider<T>(
      key: key,
      builder: builder,
      child: child,
    );
  }
}

class _BlocProviderState<T extends Bloc<dynamic, dynamic>>
    extends State<BlocProvider<T>> {
  T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.builder(context);
    if (_bloc == null) {
      throw FlutterError(
        'BlocProvider\'s builder method did not return a Bloc.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ImmutableProvider<T>(
      value: _bloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    if (widget.dispose ?? true) {
      _bloc.dispose();
    }
    super.dispose();
  }
}
