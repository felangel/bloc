// ignore_for_file: do_not_use_environment

import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';

/// A constant that is true if the application was compiled in debug mode.
const debug = !bool.fromEnvironment('dart.vm.product') &&
    !bool.fromEnvironment('dart.vm.profile');

/// {@template dev_tools}
/// A class that exposes APIs to integrate with the dev tools extension.
/// {@endtemplate}
class DevTools {
  /// {@macro dev_tools}
  DevTools() {
    if (!debug) return;
    registerExtension('ext.bloc.getBlocs', (method, parameters) async {
      return ServiceExtensionResponse.result(
        json.encode({
          'blocs': _blocs.map((bloc) => bloc.toJson()).toList(),
        }),
      );
    });
  }

  /// Notify the dev tools extension that a new bloc was created.
  void postBlocOnCreateEvent(BlocBase<dynamic> bloc) {
    if (!debug) return;
    _blocs.add(bloc);
    _postEvent('bloc:onCreate', bloc.toJson());
  }

  /// Notify the dev tools extension that a bloc was closed.
  void postBlocOnCloseEvent(BlocBase<dynamic> bloc) {
    if (!debug) return;
    _blocs.remove(bloc);
    _postEvent('bloc:onClose', bloc.toJson());
  }

  /// Notify the dev tools extension that a bloc's state changed.
  void postBlocOnChangeEvent(BlocBase<dynamic> bloc, Change<dynamic> change) {
    _postEvent('bloc:onChange', bloc.toJson(state: change.nextState));
  }

  void _postEvent(String event, Map<String, dynamic> data) {
    if (!debug) return;
    if (extensionStreamHasListener) postEvent(event, data);
  }

  late final _blocs = <BlocBase<dynamic>>[];
}

extension on BlocBase<dynamic> {
  Map<String, dynamic> toJson({dynamic state}) {
    return {
      'name': runtimeType,
      'state': '${state ?? this.state}',
      'hash': hashCode,
    };
  }
}
