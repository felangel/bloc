import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';

void postBlocOnCreateEvent(BlocBase<dynamic> bloc) {
  _blocs.add(bloc);
  _postEvent('bloc:onCreate', _blocToJson(bloc));
}

void postBlocOnCloseEvent(BlocBase<dynamic> bloc) {
  _blocs.remove(bloc);
  _postEvent('bloc:onClose', _blocToJson(bloc));
}

void postBlocOnChangeEvent(BlocBase<dynamic> bloc, Change<dynamic> change) {
  _postEvent('bloc:onChange', _blocToJson(bloc, state: change.nextState));
}

void _postEvent(String event, Map<String, dynamic> data) {
  _init();
  if (extensionStreamHasListener) postEvent(event, data);
}

final _blocs = <BlocBase<dynamic>>[];
bool _registered = false;

void _init() {
  if (_registered) return;

  _registered = true;

  registerExtension('ext.bloc.getBlocs', (method, parameters) async {
    return ServiceExtensionResponse.result(
      json.encode({
        'blocs': _blocs.map(_blocToJson).toList(),
      }),
    );
  });
}

Map<String, dynamic> _blocToJson(BlocBase<dynamic> bloc, {dynamic state}) {
  return {
    'name': '${bloc.runtimeType}',
    'state': '${state ?? bloc.state}',
    'hash': bloc.hashCode,
  };
}
