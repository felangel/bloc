```dart
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeatherBloc, WeatherState>(
      listener: (context, state) {
        // When the weather bloc's state changes, this will be called.
        //
        // Now we can add an event to the clothing bloc without it having
        // to know about the weather bloc.
        BlocProvider.of<ClothingBloc>(context).add(ClothingBlocEvent());
      },
      child: TextButton(
        child: const Text('Hello'),
        onPressed: () {
          BlocProvider.of<WeatherBloc>(context).add(RefreshWeather());
        },
      ),
    );
  }
}
```
