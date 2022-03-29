# 6.5.1

- fix: reduce bundle size

# 6.5.0

- fix: update `BlocObserver` snippet to resolve Dart analyzer warning
- feat: determine versions via `pubspec.lock`
- feat: add `Mock` snippet
- chore: upgrade dependencies

# 6.4.0

- feat: add `_onevent` snippet for creating an internal event handler
- feat: improve `onevent` snippet to infer default event type
- feat: add new extension settings:
  - `bloc.newBlocTemplate.createDirectory` (defaults to true)
  - `bloc.newCubitTemplate.createDirectory` (defaults to true)
- refactor: remove deprecated snippets:
  - `feventwhen`
  - `feventmap`

# 6.3.0

- feat: add snippets for:
  - `MockBloc`
  - `MockCubit`
  - `Fake`

# 6.2.0

- feat: query latest package versions from pub.dev

# 6.1.0

- feat: update to latest packages
  - bloc -> ^7.2.1
  - flutter_bloc -> ^7.3.3
  - bloc_test -> ^8.5.0
- fix:(vscode): escape $ in "wrap with" and "convert to"

# 6.0.1

- chore: remove unnecessary abstract keyword from freezed template

# 6.0.0

- **BREAKING**: update to bloc ^7.2.0
  - update snippets to use `on<Event>` instead of deprecated `mapEventToState`
- feat: add `onevent` snippet to register a new `EventHandler`
- feat: update to latest packages
  - bloc -> ^7.2.0
  - flutter_bloc -> ^7.3.0
  - angular_bloc -> ^7.1.0
  - bloc_test -> ^8.2.0
  - replay_bloc -> ^0.1.0
  - bloc_concurrency -> ^0.1.0
  - sealed_flutter_bloc -> ^7.1.0

# 5.8.0

- feat: add "Convert to..." Multi-Widget Actions
  - `Convert to MultiBlocListener`
  - `Convert to MultiBlocProvider`
  - `Convert to MultiRepositoryProvider`

# 5.7.0

- feat: add snippets for `BlocSelector`
- feat: add `Wrap with BlocSelector` action
- feat: update to latest packages
  - bloc_test -> ^8.1.0
  - equatable -> ^2.0.3
  - flutter_bloc -> ^7.1.0
  - hydrated_bloc -> ^7.0.1
  - sealed_flutter_bloc -> ^7.0.0

# 5.6.2

- fix: "Wrap with..." selection issues

# 5.6.1

- feat: add snippets for `bloc_test`
- feat: add snippets for importing `bloc`, `bloc_test` and `flutter_bloc`
- fix: show code actions in refactorings menu

# 5.6.0

- feat: freezed classes no longer require [abstract](https://pub.dev/packages/freezed#the-abstract-keyword) keyword when using freezed >= 0.14.0
- feat: update `BlocObserver` snippets to support null safety and bloc v7.0.0
- feat: update to latest packages
  - bloc -> ^7.0.0
  - bloc_test -> ^8.0.0
  - equatable -> ^2.0.0
  - flutter_bloc -> ^7.0.0
  - hydrated_bloc -> ^7.0.0

# 5.5.1

- feat: improve `context.select` extension snippet

# 5.5.0

- feat: add `checkForUpdates` configuration in extension settings

# 5.4.0

- feat: add snippets for:
  - `context.read`
  - `context.select`
  - `context.watch`
- feat: update to latest packages
  - angular_bloc -> ^6.0.1
  - bloc -> ^6.1.0
  - bloc_test -> ^7.1.0
  - equatable -> ^1.2.5
  - flutter_bloc -> ^6.1.0
  - hydrated_bloc -> ^6.0.3
  - sealed_flutter_bloc -> ^6.0.0

# 5.3.2

- fix: update dependencies to fix potential security vulnerabilities

# 5.3.1

- fix: freezed cubit template typo

# 5.3.0

- feat: make templates configurable via workspace settings
- feat: improve cubit state equatable template
- fix: remove unused dependency in freezed bloc template

# 5.2.0

- feat: updates to snippets
  - `contextbloc` -> `ctxbloc`
  - `contextrepository` -> `ctxrepo`
  - `repositoryof` -> `repoof`
  - `repositoryprovider` -> `repoprovider`
  - `multirepositoryprovider` -> `multirepoprovider`
  - `blocstate` (new)
  - `blocevent` (new)

# 5.1.1

- fix: freezed template typo

# 5.1.0

- feat: add new bloc/cubit support for `package:freezed`
- feat: add snippet support for `package:freezed`
  - `fstate`: new freezed state
  - `fevent`: new freezed event
  - `feventwhen`: new freezed event.when helper function
  - `feventmap`: new freezed event.map helper function
- feat: add bloc code actions
  - Wrap with `BlocBuilder`
  - Wrap with `BlocListener`
  - Wrap with `BlocConsumer`
  - Wrap with `BlocProvider`
  - Wrap with `RepositoryProvider`

# 5.0.0

- **BREAKING**: update to latest bloc packages
  - bloc -> ^6.0.0
  - bloc_test -> ^7.0.0
  - flutter_bloc -> ^6.0.0
  - hydrated_bloc -> ^6.0.0
- fix: remove error dialog when no `pubspec.yaml` found in root

# 4.2.2

- fix: Equatable not being recognized on Windows

# 4.2.1

- fix: `CubitObserver` snippet fixes
- fix: `BlocObserver` snippet fixes

# 4.2.0

- feat: Add Open Migration Guide for `bloc`, `flutter_bloc`, and `hydrated_bloc`

# 4.1.1

- fix: package version analysis on dev_dependencies

# 4.1.0

- Include "Cubit: New Cubit" command to generate a cubit and state
- Include Cubit Ecosystem when performing package version analysis
- Infer Equatable Usage
- Update snippets to support
  - `Cubit`
  - `CubitBuilder`
  - `CubitListener`
  - `MultiCubitListener`
  - `CubitConsumer`
  - `CubitProvider`
  - `MultiCubitProvider`
  - `CubitObserver`
  - `context.cubit()`
  - `CubitProvider.of()`

# 4.0.0

Update latest package versions:

- equatable -> ^1.2.0
- bloc -> ^5.0.0
- bloc_test -> ^6.0.0
- flutter_bloc -> ^5.0.0
- hydrated_bloc -> ^5.0.0

# 3.6.0

Update latest package versions:

- bloc_test -> ^5.1.0
- hydrated_bloc -> ^4.0.0
- sealed_flutter_bloc -> ^4.0.0

# 3.5.0

Update latest package versions:

- bloc_test -> ^5.0.0
- equatable -> ^1.1.1
- angular_bloc -> ^4.0.0
- bloc -> ^4.0.0
- flutter_bloc -> ^4.0.0

# 3.4.0

Update snippets to support

- `context.bloc<MyBloc>()`
- `context.repository<MyRepository>()`

# 3.3.0

Update latest package versions:

- bloc_test -> ^4.0.0
- equatable -> ^1.1.0
- flutter_bloc -> ^3.2.0

# 3.2.0

Update bloc generator to use `parts` (removes barrel file)
Update dependency analyzer to handle `any` version

# 3.1.0

Update to support flutter_bloc `v3.1.0`
Update Snippets for:

- `BlocConsumer` (blocconsumer)
- `BlocProvider.of` (blocof)
- `RepositoryProvider.of` (repositoryof)

# 3.0.1

Hotfix for `command 'extension.new-bloc' not found`

# 3.0.0

Update to support bloc `v3.0.0`

# 2.2.0

Update snippets to support flutter_bloc `v2.1.0`

# 2.1.0

Update to support equatable `v1.0.0`

# 2.0.0

Update to support bloc `v2.0.0`

# 1.0.0

Update to support bloc `v1.0.0`

# 0.13.0

Update Snippets to support changes in bloc `v0.16.0`

# 0.12.2

Add Update Action to automatically update outdated dependencies

# 0.12.1

Add detection for outdated dependencies in workspace.

# 0.12.0

Update Snippets and New Bloc to support changes in equatable `v0.6.0`

# 0.11.1

`Equatable` enhancement to address `implicit-dynamic` warning ([#463](https://github.com/felangel/bloc/pull/463)).

# 0.11.0

Update Snippets to support changes in flutter_bloc `v0.20.0`

# 0.10.1

- Minor Documentation Updates

# 0.10.0

Update Snippets for:

- `RepositoryProvider`
- `MultiRepositoryProvider`
- `MultiBlocProvider`
- `MultiBlocListener`

to support changes in flutter_bloc `v0.19.0`

# 0.9.0

Update Snippets for:

- `ImmutableProvider`
- `ImmutableProviderTree`

to support changes in flutter_bloc `v0.18.0`

# 0.8.0

Update Snippets for:

- `BlocProvider`
- `BlocProviderTree`

to support changes in flutter_bloc `v0.17.0`

# 0.7.0

Update Snippets for:

- `BlocProvider`
- `BlocProviderTree`

to support changes in flutter_bloc `v0.16.0`

# 0.6.2

Updated `BlocDelegate` snippet to support changes in bloc `v0.13.0`

# 0.6.1

Bloc generation does not overwrite existing bloc files; it attempts to merge instead.

# 0.6.0

Added Snippets for:

- `BlocListenerTree`

# 0.5.0

Added Snippets for:

- `BlocListener`

# 0.4.2

Update BlocDelegate Snippet to include calls to `super`

# 0.4.1

Added Snippets for:

- `BlocEvent`
- `BlocState`

# 0.4.0

Support for `bloc v0.11.0`

# 0.3.2

Added `@immutable` decorator to bloc events and states

# 0.3.1

Added Snippet for `BlocDelegate`

# 0.3.0

Added Snippets for `BlocBuilder`, `BlocProvider`, and `BlocProviderTree`

# 0.2.1

Update `Equatable` usage to be "advanced"

# 0.2.0

Updated to include "Bloc: New Bloc" to generate full bloc directory structure.

# 0.1.3

Minor Documentation Updates

# 0.1.2

Minor Documentation Updates

# 0.1.1

Minor Documentation Updates

# 0.1.0

Initial Version of the Extension.

- Includes the ability to create a Bloc snippet
