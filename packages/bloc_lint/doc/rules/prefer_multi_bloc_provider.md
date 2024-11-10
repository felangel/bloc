prefer-multi-bloc-provider
===
severity: WARNING

Warns when a `BlocProvider` can be replaced by a `MultiBlocProvider`.

## Example:

❌ **BAD**:

```dart
BlocProvider<BlocA>(
  create: (context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (context) => BlocB(),
    child: Widget(),
  ),
);
```

✅ **GOOD**:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(create: (context) => BlocA()),
    BlocProvider<BlocB>(create: (context) => BlocB()),
  ],
  child: Widget(),
);
```

## Additional Resources

- [Bloc Library Documentation: Flutter Bloc Concepts / MultiBlocProvider](https://bloclibrary.dev/flutter-bloc-concepts/#multiblocprovider)