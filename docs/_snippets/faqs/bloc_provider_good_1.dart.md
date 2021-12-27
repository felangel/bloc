```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => BlocA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      },
    )
    ...
  }
}
```
