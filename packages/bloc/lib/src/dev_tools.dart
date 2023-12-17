import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';

/// {@template dev_tools}
/// A class that exposes APIs to integrate with the dev tools extension.
/// {@endtemplate}
class DevTools {
  /// {@macro dev_tools}
  DevTools() {
    registerExtension('ext.bloc.getBlocs', (method, parameters) async {
      return ServiceExtensionResponse.result(
        json.encode({
          'blocs': _blocs.map(_blocToJson).toList(),
        }),
      );
    });
  }

  /// Notify the dev tools extension that a new bloc was created.
  void postBlocOnCreateEvent(BlocBase<dynamic> bloc) {
    _blocs.add(bloc);
    _postEvent('bloc:onCreate', _blocToJson(bloc));
  }

  /// Notify the dev tools extension that a bloc was closed.
  void postBlocOnCloseEvent(BlocBase<dynamic> bloc) {
    _blocs.remove(bloc);
    _postEvent('bloc:onClose', _blocToJson(bloc));
  }

  /// Notify the dev tools extension that a bloc's state changed.
  void postBlocOnChangeEvent(BlocBase<dynamic> bloc, Change<dynamic> change) {
    _postEvent('bloc:onChange', _blocToJson(bloc, state: change.nextState));
  }

  void _postEvent(String event, Map<String, dynamic> data) {
    if (extensionStreamHasListener) postEvent(event, data);
  }

  final _blocs = <BlocBase<dynamic>>[];

  Map<String, dynamic> _blocToJson(BlocBase<dynamic> bloc, {dynamic state}) {
    return {
      'name': '${bloc.runtimeType}',
      'state': '${state ?? bloc.state}',
      'hash': bloc.hashCode,
    };
  }
}
