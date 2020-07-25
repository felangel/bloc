```dart
void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(),
        ),
      ],
      child: App(weatherRepository: weatherRepository),
    ),
  );
}
```
