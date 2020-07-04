# Migrating to v5.0.0

> Detailed instructions on how to migrate to v5.0.0 of the bloc library. Please refer to the [release log](https://github.com/felangel/bloc/releases) for more information regarding what changed in each release.

## package:bloc

### initialState has been removed

#### Rationale

As a developer, having to override `initialState` when creating a bloc presents two main issues:

- The `initialState` of the bloc can be dynamic and can also be referenced at a later point in time (even outside of the bloc itself). In some ways, this can be viewed as leaking internal bloc information to the UI layer.
- It's verbose.

**v4.x.x**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  ...
}
```

**v5.0.0**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```

?> For more information check out [#1304](https://github.com/felangel/bloc/issues/1304)

### BlocDelegate renamed to BlocObserver

#### Rationale

The name `BlocDelegate` was not an accurate description of the role that the class played. `BlocDelegate` suggests that the class plays an active role whereas in reality the intended role of the `BlocDelegate` was for it to be a passive component which simply observes all blocs in an application.

!> There should ideally be no user-facing functionality or features handled within `BlocObserver`.

**v4.x.x**

```dart
class MyBlocDelegate extends BlocDelegate {
  ...
}
```

**v5.0.0**

```dart
class MyBlocObserver extends BlocObserver {
  ...
}
```

### BlocSupervisor has been removed

#### Rationale

`BlocSupervisor` was yet another component that developers had to know about and interact with for the sole purpose of specifying a custom `BlocDelegate`. With the change to `BlocObserver` we felt it improved the developer experience to set the observer directly on the bloc itself.

?> This changed also enabled us to decouple other bloc add-ons like `HydratedStorage` from the `BlocObserver`.

**v4.x.x**

```dart
BlocSupervisor.delegate = MyBlocDelegate();
```

**v5.0.0**

```dart
Bloc.observer = MyBlocObserver();
```

## package:flutter_bloc

### BlocBuilder condition renamed to buildWhen

#### Rationale

When using `BlocBuilder`, we previously could specify a `condition` to determine whether the `builder` should rebuild.

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

The name `condition` is not very self-explanatory or obvious and more importantly, when interacting with a `BlocConsumer` the API became inconsistent because developers can provide two conditions (one for `builder` and one for `listener`). As a result, the `BlocConsumer` API exposed a `buildWhen` and `listenWhen`

```dart
BlocConsumer<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...},
  buildWhen: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...},
)
```

In order to align the API and provide a more consistent developer experience, `condition` was renamed to `buildWhen`.

**v4.x.x**

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

### BlocListener condition renamed to listenWhen

#### Rationale

For the same reasons as described above, the `BlocListener` condition was also renamed.

**v4.x.x**

```dart
BlocListener<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocListener<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...}
)
```

## package:hydrated_bloc

### HydratedStorage and HydratedBlocStorage renamed

#### Rationale

In order to improve code reuse between [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) and [hydrated_cubit](https://pub.dev/packages/hydrated_cubit), the concrete default storage implementation was renamed from `HydratedBlocStorage` to `HydratedStorage`. In addition, the `HydratedStorage` interface was renamed from `HydratedStorage` to `Storage`.

**v4.0.0**

```dart
class MyHydratedStorage implements HydratedStorage {
  ...
}
```

**v5.0.0**

```dart
class MyHydratedStorage implements Storage {
  ...
}
```

### HydratedStorage decoupled from BlocDelegate

#### Rationale

As mentioned earlier, `BlocDelegate` was renamed to `BlocObserver` and was set directly as part of the `bloc` via:

```dart
Bloc.observer = MyBlocObserver();
```

The following change was made to:

- Stay consistent with the new bloc observer API
- Keep the storage scoped to just `HydratedBloc`
- Decouple the `BlocObserver` from `Storage`

**v4.0.0**

```dart
BlocSupervisor.delegate = await HydratedBlocDelegate.build();
```

**v5.0.0**

```dart
HydratedBloc.storage = await HydratedStorage.build();
```

### Simplified Initialization

#### Rationale

Previously, developers had to manually call `super.initialState ?? DefaultInitialState()` in order to setup their `HydratedBloc` instances. This is clunky and verbose and also incompatible with the breaking changes to `initialState` in `bloc`. As a result, in v5.0.0 `HydratedBloc` initialization is identical to normal `Bloc` initialization.

**v4.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  @override
  int get initialState => super.initialState ?? 0;
}
```

**v5.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```
