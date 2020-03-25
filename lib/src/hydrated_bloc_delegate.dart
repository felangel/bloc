import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';

import '../hydrated_bloc.dart';

/// {@template hydratedblocdelegate}
/// A specialized `BlocDelegate` which handles persisting state changes
/// transparently and asynchronously.
/// {@endtemplate}
class HydratedBlocDelegate extends BlocDelegate {
  /// Instance of `HydratedStorage` used to manage persisted states.
  final HydratedStorage storage;

  /// Builds a new instance of `HydratedBlocDelegate` with the
  /// default `HydratedBlocStorage`.
  /// A custom `storageDirectory` can optionally be provided.
  ///
  /// This is the recommended way to use a `HydratedBlocDelegate`.
  /// If you want to customize `HydratedBlocDelegate`
  /// you can extend `HydratedBlocDelegate` and perform the necessary overrides.
  static Future<HydratedBlocDelegate> build({
    Directory storageDirectory,
  }) async {
    return HydratedBlocDelegate(
      await HydratedBlocStorage.getInstance(storageDirectory: storageDirectory),
    );
  }

  /// {@macro hydratedblocdelegate}
  HydratedBlocDelegate(this.storage);

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    final state = transition.nextState;
    if (bloc is HydratedBloc) {
      final stateJson = bloc.toJson(state);
      if (stateJson != null) {
        storage.write(bloc.storageToken, json.encode(stateJson));
      }
    }
  }
}
