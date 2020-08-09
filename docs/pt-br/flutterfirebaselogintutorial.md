# Tutorial Login Flutter com Firebase

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um fluxo de login do Firebase no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_firebase_login.gif)

# Flutter Firebase Login Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a Firebase Login Flow in Flutter using the Bloc library.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Setup

We'll start off by creating a brand new Flutter project

```sh
flutter create flutter_firebase_login
```

Just like in the [login tutorial](pt-br/flutterlogintutorial.md) we're going to create internal packages to better layer our application architecture and maintain clear boundaries and to maximize both reusability as well as improve testability.

In this case, the [firebase_auth](https://pub.dev/packages/firebase_auth) and [google_sign_in](https://pub.dev/packages/google_sign_in) packages are going to be our data layer so we're only going to be creating an `AuthenticationRepository` to compose data from the two API clients.

## Authentication Repository

The `AuthenticationRepository` will be responsible for abstracting the internal implementation details of how we authentication and fetch user information. In this case, it will be integrating with firebase but we can always change the internal implementation later on and our application will be unaffected.

### Setup

We'll start by created `packages/authentication_repository` and create a `pubspec.yaml`.

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/pubspec.yaml ':include')


Next, we can install the dependencies by running

```sh
flutter packages get
```

in the `authentication_repository` directory.

Just like most packages, the `authentication_repository` will define it's API surface via `packages/authentication_repository/lib/authentication_repository.dart`

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/lib/authentication_repository.dart ':include')

?> **Note**: The `authentication_repository` package will be exposing an `AuthenticationRepository` as well as models.

Next, let's take a look at the models.

### User

> The `User` model will describe a user in the context of the authentication domain. For the purposes of this example, a user will consist of an `email`, `id`, `name`, and `photo`.

?> **Note**: It's completely up to you to define what a user needs to look like in the context of your domain.

[user.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/lib/src/models/user.dart ':include')

?> **Note**: The `User` class is extending [equatable](https://pub.dev/packages/equatable) in order to override equality comparisons so that we can compare different instances of `User` by value.

?> **Tip**: It's useful to define a `static` empty `User` so that we don't have to handle `null` Users and can always work with a concrete `User` object.

### Repository

> The `AuthenticationRepository` is responsible for abstracting the underlying implementation of how a user is authenticated as well as how a user is fetched.

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/lib/src/authentication_repository.dart ':include')

The `AuthenticationRepository` exposes a `Stream<User>` which we can subscribe to in order to be notified of when a `User` changes. In addition, it exposes methods to `signUp`, `logInWithGoogle`, `logInWithEmailAndPassword`, and `logOut`.

?> **Note**: The `AuthenticationRepository` is also responsible for handling low-level errors that can occur in the data layer and exposes a clean, simple set of errors that align with the domain.

That's it for the `AuthenticationRepository`, next let's take a look at how to integrate it into the Flutter project we created.

## Firebase Setup

We need to follow the [firebase_auth usage instructions](https://pub.dev/packages/firebase_auth#usage) in order to hook up our application to firebase and enable [google_signin](https://pub.dev/packages/google_sign_in).

!> Remember to update the `google-services.json` on Android and the `GoogleService-Info.plist` & `Info.plist` on iOS otherwise the application will crash.

## Project Dependencies

We can replace the generated `pubspec.yaml` at the root of the project with the following:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/pubspec.yaml ':include')

Notice that we are specifying an assets directory for all of our applications local assets. Create an `assets` directory in the root of your project and add the [bloc logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/lib/assets/bloc_logo_small.png) asset (which we'll use later).

then install all of the dependencies

```sh
flutter packages get
```

?> **Note**: We are depending on the `authentication_repository` package via path which will allow us to iterate quickly while still maintaining a clear separation.

## main.dart

The `main.dart` file can be replaced with the following:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/main.dart ':include')

It's simply setting up some global configuration for the application and calling `runApp` with an instance of `App`.

?> **Note**: We're injecting a single instance of `AuthenticationRepository` into the `App` and it is an explicit constructor dependency.

## App

Just like in the [login tutorial](pt-br/flutterlogintutorial.md) our `app.dart` will provide an instance of the `AuthenticationRepository` to the application via `RepositoryProvider` and also creates and provides an instance of `AuthenticationBloc`. Then `AppView` consumes the `AuthenticationBloc` and handles updating the current route based on the `AuthenticationState`.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/app.dart ':include')

## Authentication Bloc

> The `AuthenticationBloc` is responsible for managing the authentication state for the application. It has a dependency on the `AuthenticationRepository` and subscribes to the `user` Stream in order to emit new states in response to changes in the current user.

### State

The `AuthenticationState` consists of an `AuthenticationStatus` and a `User`. Three named constructors are exposed: `unknown`, `authenticated`, and `unauthenticated` to make it easier to work with.

[authentication_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/bloc/authentication_state.dart ':include')

### Event

The `AuthenticationEvent` has two subclasses:

- `AuthenticationUserChanged` which notifies the bloc that the current user has changed
- `AuthenticationLogoutRequested` which notifies the bloc that the current user has requested to be logged out

[authentication_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/bloc/authentication_event.dart ':include')

### Bloc

The `AuthenticationBloc` responds to incoming `AuthenticationEvents` and transforms them into outgoing `AuthenticationStates`. Upon initialization, it immediately subscribes to the `user` stream from the `AuthenticationRepository` and adds an `AuthenticationUserChanged` event internally to process changes in the current user.

!> `close` is overridden in order to handle cancelling the internal `StreamSubscription`.

[authentication_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/bloc/authentication_bloc.dart ':include')

## Models

An `Email` and `Password` input model are useful for encapsulating the validation logic and will be used in both the `LoginForm` and `SignUpForm` (later in the tutorial.)

Both input models are made using the [formz](https://pub.dev/packages/formz) package and allow us to work with a validated object rather than a primitive type like a `String`.

### Email

[email.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/models/email.dart ':include')

### Password

[email.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/models/password.dart ':include')

## Splash

The `SplashPage` is shown while the application determines the authentication state of the user. It's just a simple `StatelessWidget` which renders an image via `Image.asset`.

[splash_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/splash/view/splash_page.dart ':include')

## Login Page

The `LoginPage` is responsible for creating and providing an instance of `LoginCubit` to the `LoginForm`.

[login_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/view/login_page.dart ':include')

?> **Tip**: It's very important to keep the creation of blocs/cubits separate from where they are consumed. This will allow you to easily inject mock instances and test your view in isolation.

## Login Cubit

> The `LoginCubit` is responsible for managing the `LoginState` of the form. It exposes APIs to `logInWithCredentials`, `logInWithGoogle`, as well as gets notified when the email/password are updated.

### State

The `LoginState` consists of an `Email`, `Password`, and `FormzStatus`. The `Email` and `Password` models extend `FormzInput` from the [formz](https://pub.dev/packages/formz) package.

[login_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/cubit/login_state.dart ':include')

### Cubit

The `LoginCubit` has a dependency on the `AuthenticationRepository` in order to sign the user in either via credentials or via google sign in.

[login_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/cubit/login_cubit.dart ':include')

?> **Note**: We used a `Cubit` instead of a `Bloc` here because the `LoginState` is fairly simple and localized. Even without events, we can still have a fairly good sense of what happened just by looking at the changes from one state to another and our code is a lot simpler and more concise.

## Login Form

The `LoginForm` is a responsible for rendering the form in response to the `LoginState` and invokes methods on the `LoginCubit` in response to user interactions.

[login_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/view/login_form.dart ':include')

The `LoginForm` also renders a "Create Account" button which navigates to the `SignUpPage` where a user can create a brand new account.

## Sign Up Page

> The `SignUp` structure mirrors the `Login` structure and consists of a `SignUpPage`, `SignUpView`, and `SignUpCubit`.

The `SignUpPage` is just responsible for creating and providing an instance of the `SignUpCubit` to the `SignUpForm` (exactly like in `LoginPage`).

[sign_up_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/view/sign_up_page.dart ':include')

?> **Note**: Just as in the `LoginCubit`, the `SignUpCubit` has a dependency on the `AuthenticationRepository` in order to create new user accounts.

## Sign Up Cubit

The `SignUpCubit` manages the state of the `SignUpForm` and communicates with the `AuthenticationRepository` in order to create new user accounts.

### State

The `SignUpState` reuses the same `Email` and `Password` form input models because the validation logic is the same.

[sign_up_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/cubit/sign_up_state.dart ':include')

### Cubit

The `SignUpCubit` is extremely similar to the `LoginCubit` with the main exception being it exposes an API to submit the form as opposed to login.

[sign_up_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/cubit/sign_up_cubit.dart ':include')

## Home Page

After a user either successfully logs in or signs up, the `user` stream will be updated which will trigger a state change in the `AuthenticationBloc` and will result in the `AppView` pushing the `HomePage` route onto the navigation stack.

From the `HomePage`, the user can view their profile information and log out by tapping the exit icon in the `AppBar`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/home/view/home_page.dart ':include')

?> **Note**: A `widgets` directory was created alongside the `view` directory within the `home` feature for reusable components that are specific to that particular feature. In this case a simple `Avatar` widget is exported and used within the `HomePage`.

?> **Note**: When the logout `IconButton` is tapped, a `AuthenticationLogoutRequested` event is added to the `AuthenticationBloc` which signs the user out and navigates them back to the `LoginPage`.

At this point we have a pretty solid login implementation using Firebase and we have decoupled our presentation layer from the business logic layer by using the Bloc Library.

The full source for this example can be found [here](https://github.com/felangel/bloc/tree/master/examples/flutter_firebase_login).