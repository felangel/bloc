```dart
class _WeatherState extends State<Weather> {
  ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ...
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoadSuccess) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          builder: (context, state) {
            ...
          }
        ),
      )
    )
  }
}
```
