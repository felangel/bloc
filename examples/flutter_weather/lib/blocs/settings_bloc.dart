import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_weather/models/models.dart';

abstract class SettingsEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingsEvent {}

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  SettingsState({@required this.temperatureUnits})
      : assert(temperatureUnits != null),
        super([temperatureUnits]);
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState =>
      SettingsState(temperatureUnits: TemperatureUnits.celsius);

  @override
  Stream<SettingsState> mapEventToState(
    SettingsState currentState,
    SettingsEvent event,
  ) async* {
    if (event is TemperatureUnitsToggled) {
      yield SettingsState(
        temperatureUnits:
            currentState.temperatureUnits == TemperatureUnits.celsius
                ? TemperatureUnits.fahrenheit
                : TemperatureUnits.celsius,
      );
    }
  }
}
