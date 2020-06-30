```dart
return RefreshIndicator(
  onRefresh: () {
    BlocProvider.of<WeatherBloc>(context).add(
      WeatherRefreshRequested(city: state.weather.location),
    );
    return _refreshCompleter.future;
  },
  child: ListView(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 100.0),
        child: Center(
          child: Location(location: weather.location),
        ),
      ),
      Center(
        child: LastUpdated(dateTime: weather.lastUpdated),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Center(
          child: CombinedWeatherTemperature(
            weather: weather,
          ),
        ),
      ),
    ],
  ),
);
```
