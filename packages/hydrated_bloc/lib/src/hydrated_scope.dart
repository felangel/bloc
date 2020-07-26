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
        final temp = HydratedMixin.storage;
        final storage = HydratedMixin.storage = _storage(token);
        final cubit = create(context);
        HydratedMixin.storage = temp;
        if (storage == null) cubit.addError(_error(token));
        return cubit;
      };
    });
  }

  static final _storages = <String, Storage>{};

  /// Can return `null` when [Storage] is missing.
  static Storage _storage(String token) => _storages[token];

  static void _config(Map<String, Storage> config) {
    for (final key in config.keys) {
      _storages.putIfAbsent(key, () => config[key]);
    }
  }

  static ScopeStorageNotFound _error(String token) {
    return ScopeStorageNotFound(token);
  }
}

/// {@template scope_storage_not_found}
/// Exception thrown if there was no [HydratedStorage] specified.
/// This is most likely due to forgetting to setup the [HydratedScope.config()]:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   HydratedScope.config({
///     "myscope": await HydratedStorage.build(scope:"myscope")
///   });
///   runApp(MyApp());
/// }
/// ```
///
/// {@endtemplate}
class ScopeStorageNotFound implements Exception {
  /// {@macro scope_storage_not_found}
  const ScopeStorageNotFound(this.scopeToken);

  /// Token of scope, storage wasn't found for.
  final String scopeToken;

  @override
  String toString() {
    return 'Storage was accessed before it was initialized.\n'
        'Please ensure that storage has been initialized.\n\n'
        'For example:\n\n'
        'HydratedScope.config({'
        '   "$scopeToken": await HydratedStorage.build(scope: "$scopeToken")'
        '});';
  }
}
