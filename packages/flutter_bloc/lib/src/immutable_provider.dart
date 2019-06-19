import 'package:flutter/material.dart';

import 'copyable.dart';

/// A Flutter widget which provides an immutable value to its children via `ImmutableProvider.of(context)`.
/// It is used as a DI widget so that a single instance of an immutable value can be provided
/// to multiple widgets within a subtree.
class ImmutableProvider<T> extends InheritedWidget with Copyable {
  /// The immutable value which will be made availablee to the subtree
  final T value;

  const ImmutableProvider({
    Key key,
    @required this.value,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;

  /// Necessary to obtain generic [Type]
  /// https://github.com/dart-lang/sdk/issues/11923
  static Type _typeOf<T>() => T;

  /// Method that allows widgets to access the value as long as their `BuildContext`
  /// contains an `ImmutableProvider` instance.
  static T of<T>(BuildContext context) {
    final type = _typeOf<ImmutableProvider<T>>();
    final provider = context
        .ancestorInheritedElementForWidgetOfExactType(type)
        ?.widget as ImmutableProvider<T>;

    if (provider == null) {
      throw FlutterError(
        """
        ImmutableProvider.of() called with a context that does not contain a value of type $T.
        No ancestor could be found starting from the context that was passed to ImmutableProvider.of<$T>().
        This can happen if the context you use comes from a widget above the ImmutableProvider.
        This can also happen if you used ImmutableProviderTree and didn\'t explicity provide 
        the ImmutableProvider types: ImmutableProvider(value: $T()) instead of ImmutableProvider<$T>(value: $T()).
        The context used was: $context
        """,
      );
    }

    return provider.value;
  }

  /// Clones the current [ImmutableProvider] with a new child [Widget].
  /// All other values, including `key` and `value` are preserved.
  @override
  ImmutableProvider<T> copyWith(Widget child) {
    return ImmutableProvider<T>(
      key: key,
      value: value,
      child: child,
    );
  }
}
