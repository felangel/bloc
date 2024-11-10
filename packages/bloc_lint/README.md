Bloc Lint
===

Custom linter rules for Flutter projects using the [bloc library](https://bloclibrary.dev/). This package is based on 
[dart_custom_lint](https://github.com/invertase/dart_custom_lint) package.

## Usage

Add the following to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  custom_lint: ^0.7.0
  bloc_lint: ^0.1.0
```

Add the following to your `analysis_options.yaml` file:

```yaml
analyzer:
  plugins:
    - custom_lint
```

That's it! After running pub get (and possibly restarting their IDE), users should now see our custom lints in their
Dart files. You can also run `dart pub custom_lint` to run the linter in your CLI.

## Tests

The example folder contains a dart project to unit test the rules. (see custom_lint readme for more info)

## Implemented Rules

- [avoid_public_methods_on_bloc](doc/rules/avoid_public_methods_on_bloc.md)
- [avoid_public_properties_on_bloc_and_cubit](doc/rules/avoid_public_properties_on_bloc_and_cubit.md)
- [event_base_class_suffix](doc/rules/event_base_class_suffix.md)
- [prefer_multi_bloc_listener](doc/rules/prefer_multi_bloc_listener.md)
- [prefer_multi_bloc_provider](doc/rules/prefer_multi_bloc_provider.md)
- [prefer_multi_repository_provider](doc/rules/prefer_multi_repository_provider.md)
- [state_base_class_suffix](doc/rules/state_base_class_suffix.md) 