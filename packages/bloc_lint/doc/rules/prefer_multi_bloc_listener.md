prefer-multi-bloc-listener
===
exists from: 0.1.0

severity: WARNING

Warns when a `BlocListener` can be replaced by a `MultiBlocListener`.

## Example:

❌ **BAD**:

```dart
BlocListener<ACubit, AState>(
  listener: (BuildContext context, state) {},
    child: BlocListener<BCubit, BState>(
      listener: (BuildContext context, state) {},
    ),
);
```

✅ **GOOD**:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<ACubit, AState>(
      listener: (BuildContext context, state) {},
    ),
    BlocListener<BCubit, BState>(
      listener: (BuildContext context, state) {},
    ),
  ],
  child: Container(),
);
```

## Additional Resources

- [Bloc Library Documentation: Flutter Bloc Concepts / MultiBlocListener](https://bloclibrary.dev/flutter-bloc-concepts/#multibloclistener)