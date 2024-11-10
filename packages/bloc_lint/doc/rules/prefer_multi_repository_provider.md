prefer-multi-repository-provider
===
severity: WARNING

Warns when a `RepositoryProvider` can be replaced by a `MultiRepositoryProvider`.

## Example:

❌ **BAD**:

```dart
RepositoryProvider(
  create: (_) => RepositoryA(),
    child: RepositoryProvider(
    create: (_) => RepositoryB(),
  ),
);
```

✅ **GOOD**:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider(create: (_) => RepositoryA()),
    RepositoryProvider(create: (_) => RepositoryB()),
  ],
  child: Container(),
);
```

## Additional Resources

- [Bloc Library Documentation: Flutter Bloc Concepts / MultiRepositoryProvider](https://bloclibrary.dev/flutter-bloc-concepts/#multirepositoryprovider)