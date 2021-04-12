# Bloc Plugin for IntelliJ and Android Studio

![dialog](https://github.com/felangel/bloc/raw/master/extensions/intellij/assets/dialog.png)

## Introduction

Bloc plugin for [IntelliJ](https://www.jetbrains.com/idea/) and [Android Studio](https://developer.android.com/studio/) with support for the [Bloc Library](https://bloclibrary.dev) and provides tools for effectively creating Blocs and Cubits for both [Flutter](https://flutter.dev/) and [AngularDart](https://angulardart.dev/) apps.

## Installation

You can find the plugin in the official IntelliJ and Android Studio marketplace:

- [Bloc](https://plugins.jetbrains.com/plugin/12129-bloc)

### How to use

Simply right click on the File Project view, go to `New -> Bloc Class`, give it a name, select if you want to use [Equatable](https://github.com/felangel/equatable), and click on `OK` to see all the boilerplate generated.

### Quick code action

Wrapping a widget is also possible with `Alt + ENTER` shortcut.
If you wish to disable this quick code action `(Bloc) Wrap with` you can do it so by going to
`Settings - Editor - Intentions - Bloc`.

![intention_settings](https://github.com/felangel/bloc/raw/master/extensions/intellij/assets/intention_settings.png)

## Snippets

### Bloc

| Shortcut            | Description                                     |
| ------------------- | ----------------------------------------------- |
| `importbloc`        | Imports `package:bloc`                          |
| `importflutterbloc` | Imports `package:flutter_bloc`                  |
| `importbloctest`    | Imports `package:bloc_test`                     |
| `bloc`              | Creates a bloc class                            |
| `cubit`             | Creates a cubit class                           |
| `blocobserver`      | Creates a `BlocObserver` class                  |
| `blocprovider`      | Creates a `BlocProvider` widget                 |
| `multiblocprovider` | Creates a `MultiBlocProvider` widget            |
| `repoprovider`      | Creates a `RepositoryProvider` widget           |
| `multirepoprovider` | Creates a `MultiRepositoryProvider` widget      |
| `blocbuilder`       | Creates a `BlocBuilder` widget                  |
| `bloclistener`      | Creates a `BlocListener` widget                 |
| `multibloclistener` | Creates a `MultiBlocListener` widget            |
| `blocconsumer`      | Creates a `BlocConsumer` widget                 |
| `blocof`            | Shortcut for `BlocProvider.of()`                |
| `repoof`            | Shortcut for `RepositoryProvider.of()`          |
| `read`              | Shortcut for `context.read()`                   |
| `watch`             | Shortcut for `context.watch()`                  |
| `select`            | Shortcut for `context.select()`                 |
| `blocstate`         | Creates a state class                           |
| `blocevent`         | Creates an event class                          |
| `bloctest`          | Creates a `blocTest` with build, act and expect |

### Freezed Bloc

| Shortcut     | Description                                                     |
| ------------ | --------------------------------------------------------------- |
| `feventwhen` | Creates a map event to state function with freeze.when function |
| `feventmap`  | Creates a map event to state function with freeze.map function  |
| `fstate`     | Creates a sub state                                             |
| `fevent`     | Creates a sub event                                             |

## Deployment

Using [Plugin Repository](http://www.jetbrains.org/intellij/sdk/docs/plugin_repository/index.html)
