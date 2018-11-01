<img src="https://raw.githubusercontent.com/felangel/bloc/master/doc/assets/bloc_logo_full.png" height="60" alt="Bloc" />

[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Gitter](https://img.shields.io/badge/gitter-bloc-yellow.svg)](https://gitter.im/bloc_package/Lobby)

---

A collection of packages that help implement the [Bloc pattern](https://www.youtube.com/watch?v=fahC3ky_zW0).

| Package | Pub |
|--------|-----|
| [bloc](./packages/bloc/) | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dartlang.org/packages/bloc) |
| [flutter_bloc](./packages/flutter_bloc/) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dartlang.org/packages/flutter_bloc) |
| [angular_bloc](./packages/angular_bloc/) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dartlang.org/packages/angular_bloc) |

## Overview

<img src="https://raw.githubusercontent.com/felangel/bloc/master/doc/assets/bloc_architecture.png" alt="Bloc Architecture" />

The goal of this package is to make it easy to separate _presentation_ from _business logic_, facilitating testability and reusability.

## Documentation
- [Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Flutter Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Angular Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Examples

### Dart

- [Simple Counter Example](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - an example of how to create a `CounterBloc` (pure dart).

### Flutter

- [Simple Counter Example](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example) - an example of how to create a `CounterBloc` to implement the classic Flutter Counter app.
- [Login Flow Example](https://github.com/felangel/Bloc/tree/master/examples/flutter_login) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a Login Flow.
- [AngularDart Counter Example](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - an example of how to use a `CounterBloc` in an AngularDart app.

## Articles

- [bloc package](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - An intro to the bloc package with high level architecture and examples.
- [flutter login tutorial with flutter_bloc package](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - How to create a full login flow using the bloc and flutter_bloc packages.

## Contributors

- [Felix Angelov](https://github.com/felangel)
