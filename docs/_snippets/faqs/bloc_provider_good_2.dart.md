```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => BlocA(),
    child: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () {
          final blocA = BlocProvider.of<BlocA>(context);
          ...
        },
      ),
    ),
  );
}
```
