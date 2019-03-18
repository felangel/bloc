# todos_repository_simple

A concrete implementation of the `todos_repository` for Flutter apps.

## Getting Started

The code is in `todos_repository/lib/`.

The tests can be run from the command line

```
cd flutter_architecture_samples/todos_repository
flutter test
```

## Key Concepts

  * Provides an implementation of the data layer
  * Can be a pure Dart library or a Flutter library

## Provides an implementation of the data layer

This library implements the `todos_repository`. It uses a File Storage and Web Client (currently a Mock).

This implementation tries first to load the todos from storage, then falls back to web if none are found. It persists changes to both the file system and the web service.

## Dart Library or Flutter Library?

Generally speaking, if a library can be a pure Dart library, it probably should be. This makes it far easier to reuse because it has far fewer dependencies and easier to test because you do not have to mock out the Flutter environment.

For example, in order to test the File Storage part of this library, we have two options:

  1. Make this a pure Dart Lib
     - The `FileStorage` class takes a `getDirectory` function that will provide the correct `Directory` for the given situation.
     - In Flutter, we'll pass through the `path_provider` function `getApplicationDocumentDirectory`.
     - In tests, we'll pass through a function that provides a temporary directory on disk.
  2. Make this a Flutter library
      - In this case, the library will require `path_provider` directly.
      - In your flutter app, everything should "just work" since you're depending on the environment directly.
      - In tests, you need to mock the `MethodChannel` and return a temporary directory on disk for the correct situation.

Overall, it's not too much more difficult to test these one way or the other. However, if you can avoid pulling in large dependencies, such as Flutter, you should. This will make it easier to use this library in other, pure Dart libs, or even in web projects, and will still function perfectly within your Flutter projects.
