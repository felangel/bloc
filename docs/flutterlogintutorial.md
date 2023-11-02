# Flutter Login Tutorial

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> In the following tutorial, we're going to build a Login Flow in Flutter using the Bloc library.

![demo](./assets/gifs/flutter_login.gif)

## Key Topics

- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), Flutter widget which provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), Flutter widget that handles building the widget in response to new states.
- Using Cubit and Bloc. [What's the difference?](/coreconcepts?id=cubit-vs-bloc)
- Adding events with [context.read](/migration?id=❗contextbloc-and-contextrepository-are-deprecated-in-favor-of-contextread-and-contextwatch).⚡
- Prevent unnecessary rebuilds with [Equatable](/faqs?id=when-to-use-equatable).
- [RepositoryProvider](/flutterbloccoreconcepts?id=repositoryprovider), a Flutter widget which provides a repository to its children.
- [BlocListener](/flutterbloccoreconcepts?id=bloclistener), a Flutter widget which invokes the listener code in response to state changes in the bloc.
- Updating the UI based on a part of a bloc state with [context.select](/migration?id=❗contextbloc-and-contextrepository-are-deprecated-in-favor-of-contextread-and-contextwatch).⚡

## Project Setup

We'll start off by creating a brand new Flutter project

```sh
flutter create flutter_login
```

Next, we can install all of our dependencies

```sh
flutter packages get
```

## Authentication Repository

The first thing we're going to do is create an `authentication_repository` package which will be responsible for managing the authentication domain.

We'll start by creating a `packages/authentication_repository` directory at the root of the project which will contain all internal packages.

At a high level, the directory structure should look like this:

```sh
├── android
├── ios
├── lib
├── packages
│   └── authentication_repository
└── test
```

Next, we can create a `pubspec.yaml` for the `authentication_repository` package:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/pubspec.yaml ':include')

?> **Note**: `package:authentication_repository` will be a pure Dart package and for simplicity we will only have a dependency on [package:meta](https://pub.dev/packages/meta) for some useful annotations.

Next up, we need to implement the `AuthenticationRepository` class itself which will be in `packages/authentication_repository/lib/src/authentication_repository.dart`.

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/src/authentication_repository.dart ':include')

The `AuthenticationRepository` exposes a `Stream` of `AuthenticationStatus` updates which will be used to notify the application when a user signs in or out.

In addition, there are `logIn` and `logOut` methods which are stubbed for simplicity but can easily be extended to authenticate with `FirebaseAuth` for example or some other authentication provider.

?> **Note**: Since we are maintaining a `StreamController` internally, a `dispose` method is exposed so that the controller can be closed when it is no longer needed.

Lastly, we need to create `packages/authentication_repository/lib/authentication_repository.dart` which will contain the public exports:

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/authentication_repository.dart ':include')

That's it for the `AuthenticationRepository`, next we'll work on the `UserRepository`.

## User Repository

Just like with the `AuthenticationRepository`, we will create a `user_repository` package inside the `packages` directory.

```sh
├── android
├── ios
├── lib
├── packages
│   ├── authentication_repository
│   └── user_repository
└── test
```

Next, we'll create the `pubspec.yaml` for the `user_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/pubspec.yaml ':include')

The `user_repository` will be responsible for the user domain and will expose APIs to interact with the current user.

The first thing we will define is the user model in `packages/user_repository/lib/src/models/user.dart`:

[user.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/user.dart ':include')

For simplicity, a user just has an `id` property but in practice we might have additional properties like `firstName`, `lastName`, `avatarUrl`, etc...

?> **Note**: [package:equatable](https://pub.dev/packages/equatable) is used to enable value comparisons of the `User` object.

Next, we can create a `models.dart` in `packages/user_repository/lib/src/models` which will export all models so that we can use a single import state to import multiple models.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/models.dart ':include')

Now that the models have been defined, we can implement the `UserRepository` class in `packages/user_repository/lib/src/user_repository.dart`.

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/user_repository.dart ':include')

For this simple example, the `UserRepository` exposes a single method `getUser` which will retrieve the current user. We are stubbing this but in practice this is where we would query the current user from the backend.

Almost done with the `user_repository` package -- the only thing left to do is to create the `user_repository.dart` file in `packages/user_repository/lib` which defines the public exports:

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/user_repository.dart ':include')

Now that we have the `authentication_repository` and `user_repository` packages complete, we can focus on the Flutter application.

## Installing Dependencies

Let's start by updating the generated `pubspec.yaml` at the root of our project:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/pubspec.yaml ':include')

We can install the dependencies by running:

```sh
flutter packages get
```

## Authentication Bloc

The `AuthenticationBloc` will be responsible for reacting to changes in the authentication state (exposed by the `AuthenticationRepository`) and will emit states we can react to in the presentation layer.

The implementation for the `AuthenticationBloc` is inside of `lib/authentication` because we treat authentication as a feature in our application layer.

```sh
├── lib
│   ├── app.dart
│   ├── authentication
│   │   ├── authentication.dart
│   │   └── bloc
│   │       ├── authentication_bloc.dart
│   │       ├── authentication_event.dart
│   │       └── authentication_state.dart
│   ├── main.dart
```

?> **Tip**: Use the [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) to create blocs automatically.

### authentication_event.dart

> `AuthenticationEvent` instances will be the input to the `AuthenticationBloc` and will be processed and used to emit new `AuthenticationState` instances.

In this application, the `AuthenticationBloc` will be reacting to two different events:

- `AuthenticationStatusChanged`: notifies the bloc of a change to the user's `AuthenticationStatus`
- `AuthenticationLogoutRequested`: notifies the bloc of a logout request

[authentication_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_event.dart ':include')

Next, let's take a look at the `AuthenticationState`.

### authentication_state.dart

> `AuthenticationState` instances will be the output of the `AuthenticationBloc` and will be consumed by the presentation layer.

The `AuthenticationState` class has three named constructors:

- `AuthenticationState.unknown()`: the default state which indicates that the bloc does not yet know whether the current user is authenticated or not.

- `AuthenticationState.authenticated()`: the state which indicates that the user is current authenticated.

- `AuthenticationState.unauthenticated()`: the state which indicates that the user is current not authenticated.

[authentication_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_state.dart ':include')

Now that we have seen the `AuthenticationEvent` and `AuthenticationState` implementations let's take a look at `AuthenticationBloc`.

### authentication_bloc.dart

> The `AuthenticationBloc` manages the authentication state of the application which is used to determine things like whether or not to start the user at a login page or a home page.

[authentication_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_bloc.dart ':include')

The `AuthenticationBloc` has a dependency on both the `AuthenticationRepository` and `UserRepository` and defines the initial state as `AuthenticationState.unknown()`.

In the constructor body, the `AuthenticationBloc` subscribes to the `status` stream of the `AuthenticationRepository` and adds an `AuthenticationStatusChanged` event internally in response to a new `AuthenticationStatus`.

!> The `AuthenticationBloc` overrides `close` in order to dispose both the `StreamSubscription` as well as the `AuthenticationRepository`.

Next, the `EventHandler` handles transforming the incoming `AuthenticationEvent` instances into new `AuthenticationState` instances.

When an `AuthenticationStatusChanged` event is added if the associated status is `AuthenticationStatus.authenticated`, the `AuthentictionBloc` queries the user via the `UserRepository`.

## main.dart

Next, we can replace the default `main.dart` with:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/main.dart ':include')

?> **Note**: We are injecting a single instance of the `AuthenticationRepository` and `UserRepository` into the `App` widget (which we will get to next).

## App

`app.dart` will contain the root `App` widget for the entire application.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/app.dart ':include')

?> **Note**: `app.dart` is split into two parts `App` and `AppView`. `App` is responsible for creating/providing the `AuthenticationBloc` which will be consumed by the `AppView`. This decoupling will enable us to easily test both the `App` and `AppView` widgets later on.

?> **Note**: `RepositoryProvider` is used to provide the single instance of `AuthenticationRepository` to the entire application which will come in handy later on.

`AppView` is a `StatefulWidget` because it maintains a `GlobalKey` which is used to access the `NavigatorState`. By default, `AppView` will render the `SplashPage` (which we will see later) and it uses `BlocListener` to navigate to different pages based on changes in the `AuthenticationState`.

## Splash

> The splash feature will just contain a simple view which will be rendered right when the app is launched while the app determines whether the user is authenticated.

```sh
lib
└── splash
    ├── splash.dart
    └── view
        └── splash_page.dart
```

[splash_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/splash/view/splash_page.dart ':include')

?> **Tip**: `SplashPage` exposes a static `Route` which makes it very easy to navigate to via `Navigator.of(context).push(SplashPage.route())`;

## Login

> The login feature contains a `LoginPage`, `LoginForm` and `LoginBloc` and allows users to enter a username and password to log into the application.

```sh
├── lib
│   ├── login
│   │   ├── bloc
│   │   │   ├── login_bloc.dart
│   │   │   ├── login_event.dart
│   │   │   └── login_state.dart
│   │   ├── login.dart
│   │   ├── models
│   │   │   ├── models.dart
│   │   │   ├── password.dart
│   │   │   └── username.dart
│   │   └── view
│   │       ├── login_form.dart
│   │       ├── login_page.dart
│   │       └── view.dart
```

### Login Models

We are using [package:formz](https://pub.dev/packages/formz) to create reusable and standard models for the `username` and `password`.

#### Username

[username.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/username.dart ':include')

For simplicity, we are just validating the username to ensure that it is not empty but in practice you can enforce special character usage, length, etc...

#### Password

[password.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/password.dart ':include')

Again, we are just performing a simple check to ensure the password is not empty.

#### Models Barrel

Just like before, there is a `models.dart` barrel to make it easy to import the `Username` and `Password` models with a single import.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/models.dart ':include')

### Login Bloc

> The `LoginBloc` manages the state of the `LoginForm` and takes care validating the username and password input as well as the state of the form.

#### login_event.dart

In this application there are three different `LoginEvent` types:

- `LoginUsernameChanged`: notifies the bloc that the username has been modified.
- `LoginPasswordChanged`: notifies the bloc that the password has been modified.
- `LoginSubmitted`: notifies the bloc that the form has been submitted.

[login_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_event.dart ':include')

#### login_state.dart

The `LoginState` will contain the status of the form as well as the username and password input states.

[login_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_state.dart ':include')

?> **Note**: The `Username` and `Password` models are used as part of the `LoginState` and the status is also part of [package:formz](https://pub.dev/packages/formz).

#### login_bloc.dart

> The `LoginBloc` is responsible for reacting to user interactions in the `LoginForm` and handling the validation and submission of the form.

[login_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_bloc.dart ':include')

The `LoginBloc` has a dependency on the `AuthenticationRepository` because when the form is submitted, it invokes `logIn`. The initial state of the bloc is `pure` meaning neither the inputs nor the form has been touched or interacted with.

Whenever either the `username` or `password` change, the bloc will create a dirty variant of the `Username`/`Password` model and update the form status via the `Formz.validate` API.

When the `LoginSubmitted` event is added, if the current status of the form is valid, the bloc makes a call to `logIn` and updates the status based on the outcome of the request.

Next let's take a look at the `LoginPage` and `LoginForm`.

### Login Page

> The `LoginPage` is responsible for exposing the `Route` as well as creating and providing the `LoginBloc` to the `LoginForm`.

[login_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_page.dart ':include')

?> **Note**: `RepositoryProvider.of<AuthenticationRepository>(context)` is used to lookup the instance of `AuthenticationRepository` via the `BuildContext`.

### Login Form

> The `LoginForm` handles notifying the `LoginBloc` of user events and also responds to state changes using `BlocBuilder` and `BlocListener`.

[login_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_form.dart ':include')

`BlocListener` is used to show a `SnackBar` if the login submission fails. In addition, `BlocBuilder` widgets are used to wrap each of the `TextField` widgets and make use of the `buildWhen` property in order to optimize for rebuilds. The `onChanged` callback is used to notify the `LoginBloc` of changes to the username/password.

The `_LoginButton` widget is only enabled if the status of the form is valid and a `CircularProgressIndicator` is shown in its place while the form is being submitted.

## Home

> Upon a successful `logIn` request, the state of the `AuthenticationBloc` will change to `authenticated` and the user will be navigated to the `HomePage` where we display the user's `id` as well as a button to log out.

```sh
├── lib
│   ├── home
│   │   ├── home.dart
│   │   └── view
│   │       └── home_page.dart
```

### Home Page

The `HomePage` can access the current user id via `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` and displays it via a `Text` widget. In addition, when the logout button is tapped, an `AuthenticationLogoutRequested` event is added to the `AuthenticationBloc`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/home/view/home_page.dart ':include')

?> **Note**: `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` will trigger updates if the user id changes.

At this point we have a pretty solid login implementation and we have decoupled our presentation layer from the business logic layer by using Bloc.

The full source for this example (including unit and widget tests) can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
