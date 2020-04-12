```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) {
        return Text('$count');
      },
    );
  }
}
```
