part of 'settings_cubit.dart';

enum TemperatureUnits { fahrenheit, celsius }

class SettingsState extends Equatable {
  const SettingsState({this.temperatureUnits = TemperatureUnits.fahrenheit});

  final TemperatureUnits temperatureUnits;

  @override
  List<Object> get props => [temperatureUnits];
}
