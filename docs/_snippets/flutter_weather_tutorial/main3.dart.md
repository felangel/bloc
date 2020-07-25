```dart
void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(
    BlocProvider<ThemeBloc>(
      create: (context) => ThemeBloc(),
      child: App(weatherRepository: weatherRepository),
    ),
  );
}
```
