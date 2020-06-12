```dart
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:http/http.dart' as http;

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );

  runApp(App(weatherRepository: weatherRepository));
}
```
