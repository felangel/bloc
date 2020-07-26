import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'hydrated_cubit.dart';
import 'hydrated_storage.dart';

/// Hydrated storage scope.
class HydratedScope extends InheritedWidget {
  /// Scope is defined by it's [token].
  const HydratedScope({
    Key key,
    @required this.token,
    @required Widget child,
  })  : assert(token != null),
        assert(child != null),
        super(key: key, child: child);

  /// Scope's unique identification token.
  final String token;

  /// Retrieve scope from context.
  static HydratedScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HydratedScope>();
  }

  @override
  bool updateShouldNotify(HydratedScope oldWidget) {
    return oldWidget.token != token;
  }

  /// Method to configure hydrated scopes app-wide.
  /// Can be called multiple times, or from `build`.
  static void config(Map<String, Storage> config) {
    _config(config);

    if (!_wrapped) _wrap();
    _wrapped = true;
  }

  static bool _wrapped = false;

  static void _wrap() {
    BlocProvider.addWrapper((context, create) {
      final token = HydratedScope.of(context)?.token;
      if (token == null) return create;
      return (context) {
        HydratedMixin.storage = _storage(token);
        return create(context);
        // final cub = create(context);
        // if (storage == null) cub.error();
        // return cub;
      };
    });
  }

  static final _storages = <String, Storage>{};

  static Storage _storage(String token) {
    final storage = _storages[token];
    if (storage == null) _error();
    return storage;
  }

  static void _config(Map<String, Storage> config) {
    for (final key in config.keys) {
      _storages.putIfAbsent(key, () => config[key]);
    }
  }

  static void _error() {}
}
