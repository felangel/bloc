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
