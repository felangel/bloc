```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => BlocA(),
    child: ElevatedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      }
    )
  );
}
```
