<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_test_logo_full.png" height="60" alt="Bloc Test Package" />

[![Pub](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)
[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Flutter.io](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)
[![Gitter](https://img.shields.io/badge/gitter-chat-hotpink.svg)](https://gitter.im/bloc_package/Lobby)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A Dart package that makes testing blocs easy.

This package is built to work with [bloc](https://pub.dev/packages/bloc) and [mockito](https://pub.dev/packages/mockito).

## Create a Mock Bloc

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

class MockCounterBloc extends Mock implements CounterBloc {}
```

## Stub the Bloc Stream

```dart
// Create a mock instance
final counterBloc = MockCounterBloc();

// Stub the bloc `Stream`
whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));

// Assert that the bloc emits the stubbed `Stream`.
expectLater(counterBloc, emitsInOrder(<int>[0, 1, 2, 3])))
```

## Dart Versions

- Dart 2: >= 2.0.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)
