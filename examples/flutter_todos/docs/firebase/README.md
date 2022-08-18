# Flutter Todos Firebase

## Getting Started 🚀

This project contains 3 flavors:

- development
- staging
- production

## Firestore - Setup 😍

Using Firebase Firestore as the backend requires per-project setup.

### Install

```
firebase login
dart pub global activate flutterfire_cli
```

For more information follow the steps at https://firebase.google.com/docs/flutter/setup

### Configure

Based on the chosen flavor apply once the `flutterfire configure` command to integrate firebase into your project.

```sh
# Development
$ flutterfire configure -a 'com.example.verygoodcore.flutter_todos.dev' -i 'com.example.verygoodcore.flutter-todos.dev'

# Staging
$ flutterfire configure -a 'com.example.verygoodcore.flutter_todos.stg' -i 'com.example.verygoodcore.flutter-todos.stg'

# Production
$ flutterfire configure -a 'com.example.verygoodcore.flutter_todos' -i 'com.example.verygoodcore.flutter-todos'
```

## Getting Started 🚀

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart --dart-define=todos_api=firestore

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart --dart-define=todos_api=firestore

# Production
$ flutter run --flavor production --target lib/main_production.dart --dart-define=todos_api=firestore
```

_\*Flutter Todos works on iOS, Android, and Web._

---

## FAQ

Q: What does `flutterfire configure` does to my project?

A: The command fetchs credentails from Firebase API and writen them locally into the project directories.
