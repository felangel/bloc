```dart
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeatherCubit, WeatherState>(
      listener: (context, state) {
        // When the first bloc's state changes, this will be called.
        //
        // Now we can add an event to the second bloc without it having
        // to know about the first bloc.
        BlocProvider.of<SecondBloc>(context).add(SecondBlocEvent());
      },
      child: TextButton(
        child: const Text('Hello'),
        onPressed: () {
          BlocProvider.of<FirstBloc>(context).add(FirstBlocEvent());
        },
      ),
    );
  }
}
```
