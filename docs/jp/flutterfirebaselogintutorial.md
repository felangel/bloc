# Flutter Firebase Login Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a Firebase Login Flow in Flutter using the Bloc library.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Setup

We'll start off by creating a brand new Flutter project

[flutter_create.sh](../_snippets/flutter_firebase_login_tutorial/flutter_create.sh.md ':include')

We can then replace the contents of `pubspec.yaml` with

[pubspec.yaml](../_snippets/flutter_firebase_login_tutorial/pubspec.yaml.md ':include')

Notice that we are specifying an assets directory for all of our applications local assets. Create an `assets` directory in the root of your project and add the [flutter logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png) asset (which we'll use later).

then install all of the dependencies

[flutter_packages_get.sh](../_snippets/flutter_firebase_login_tutorial/flutter_packages_get.sh.md ':include')

The last thing we need to do is follow the [firebase_auth usage instructions](https://pub.dev/packages/firebase_auth#usage) in order to hook up our application to firebase and enable [google_signin](https://pub.dev/packages/google_sign_in).

## User Repository

Just like in the [flutter login tutorial](./flutterlogintutorial.md), we're going to need to create our `UserRepository` which will be responsible for abstracting the underlying implementation for how we authenticate and retrieve user information.

Let's create `user_repository.dart` and get started.

We can start by defining our `UserRepository` class and implementing the constructor. You can immediately see that the `UserRepository` will have a dependency on both `FirebaseAuth` and `GoogleSignIn`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository_constructor.dart.md ':include')

?> **Note:** If `FirebaseAuth` and/or `GoogleSignIn` are not injected into the `UserRepository`, then we instantiate them internally. This allows us to be able to inject mock instances so that we can easily test the `UserRepository`.

The first method we're going to implement we will call `signInWithGoogle` and it will authenticate the user using the `GoogleSignIn` package.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_google.dart.md ':include')

Next, we'll implement a `signInWithCredentials` method which will allow users to sign in with their own credentials using `FirebaseAuth`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_credentials.dart.md ':include')

Up next, we need to implement a `signUp` method which allows users to create an account if they choose not to use Google Sign In.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_up.dart.md ':include')

We need to implement a `signOut` method so that we can give users the option to logout and clear their profile information from the device.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_out.dart.md ':include')

Lastly, we will need two additional methods: `isSignedIn` and `getUser` to allow us to check if a user is already authenticated and to retrieve their information.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/is_signed_in_and_get_user.dart.md ':include')

?> **Note:** `getUser` is only returning the current user's email address for the sake of simplicity but we can define our own User model and populate it with a lot more information about the user in more complex applications.

Our finished `user_repository.dart` should look like this:

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository.dart.md ':include')

Next up, we're going to build our `AuthenticationBloc` which will be responsible for handling the `AuthenticationState` of the application in response to `AuthenticationEvents`.

## Authentication States

We need to determine how we’re going to manage the state of our application and create the necessary blocs (business logic components).

At a high level, we’re going to need to manage the user’s Authentication State. A user's authentication state can be one of the following:

- AuthenticationInitial - waiting to see if the user is authenticated or not on app start.
- AuthenticationSuccess - successfully authenticated
- AuthenticationFailure - not authenticated

Each of these states will have an implication on what the user sees.

For example:

- if the authentication state was AuthenticationInitial, the user might be seeing a splash screen
- if the authentication state was AuthenticationSuccess, the user might see a home screen.
- if the authentication state was AuthenticationFailure, the user might see a login form.

> It's critical to identify what the different states are going to be before diving into the implementation.

Now that we have our authentication states identified, we can implement our `AuthenticationState` class.

Create a folder/directory called `authentication_bloc` and we can create our authentication bloc files.

[authentication_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_dir.sh.md ':include')

?> **Tip:** You can use the [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) or [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) extensions to autogenerate the files for you.

[authentication_state.dart](../_snippets/flutter_firebase_login_tutorial/authentication_state.dart.md ':include')

?> **Note**: The [`equatable`](https://pub.dev/packages/equatable) package is used in order to be able to compare two instances of `AuthenticationState`. By default, `==` returns true only if the two objects are the same instance.

?> **Note**: `toString` is overridden to make it easier to read an `AuthenticationState` when printing it to the console or in `Transitions`.

!> Since we're using `Equatable` to allow us to compare different instances of `AuthenticationState` we need to pass any properties to the superclass. Without `List<Object> get props => [displayName]`, we will not be able to properly compare different instances of `AuthenticationSuccess`.

## Authentication Events

Now that we have our `AuthenticationState` defined we need to define the `AuthenticationEvents` which our `AuthenticationBloc` will be reacting to.

We will need:

- an `AuthenticationStarted` event to notify the bloc that it needs to check if the user is currently authenticated or not.
- a `AuthenticationLoggedIn` event to notify the bloc that the user has successfully logged in.
- a `AuthenticationLoggedOut` event to notify the bloc that the user has successfully logged out.

[authentication_event.dart](../_snippets/flutter_firebase_login_tutorial/authentication_event.dart.md ':include')

## Authentication Bloc

Now that we have our `AuthenticationState` and `AuthenticationEvents` defined, we can get to work on implementing the `AuthenticationBloc` which is going to manage checking and updating a user's `AuthenticationState` in response to `AuthenticationEvents`.

We'll start off by creating our `AuthenticationBloc` class.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Note**: Just from reading the class definition, we already know this bloc is going to be converting `AuthenticationEvents` into `AuthenticationStates`.

?> **Note**: Our `AuthenticationBloc` has a dependency on the `UserRepository`.

We can start by overriding `initialState` to the `AuthenticationInitial()` state.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Now all that's left is to implement `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

We created separate private helper functions to convert each `AuthenticationEvent` into the proper `AuthenticationState` in order to keep `mapEventToState` clean and easy to read.

?> **Note:** We are using `yield*` (yield-each) in `mapEventToState` to separate the event handlers into their own functions. `yield*` inserts all the elements of the subsequence into the sequence currently being constructed, as if we had an individual yield for each element.

Our complete `authentication_bloc.dart` should now look like this:

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc.dart.md ':include')

Now that we have our `AuthenticationBloc` fully implemented, let’s get to work on the presentational layer.

## App

We'll start by removing everything from out `main.dart` and implementing our main function.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main1.dart.md ':include')

We are wrapping our entire `App` widget in a `BlocProvider` in order to make the `AuthenticationBloc` available to the entire widget tree.

?> `WidgetsFlutterBinding.ensureInitialized()` is required in Flutter v1.9.4+ before using any plugins if the code is executed before runApp.

?> `BlocProvider` also handles closing the `AuthenticationBloc` automatically so we don't need to do that.

Next we need to implement our `App` widget.

> `App` will be a `StatelessWidget` and be responsible for reacting to the `AuthenticationBloc` state and rendering the appropriate widget.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main2.dart.md ':include')

We are using `BlocBuilder` in order to render UI based on the `AuthenticationBloc` state.

So far we don't have any widgets to render but we'll come back to this once we make our `SplashScreen`, `LoginScreen`, and `HomeScreen`.

## Bloc Delegate

Before we get too far along, it's always handy to implement our own `BlocDelegate` which allows us to override `onTransition` and `onError` and will help us see all bloc state changes (transitions) and errors in one place!

Create `simple_bloc_delegate.dart` and let's quickly implement our own delegate.

[simple_bloc_delegate.dart](../_snippets/flutter_firebase_login_tutorial/simple_bloc_delegate.dart.md ':include')

Now we can hook up our `BlocDelegate` in our `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main3.dart.md ':include')

## Splash Screen

Next, we’ll need to make a `SplashScreen` widget which will be rendered while our `AuthenticationBloc` determines whether or not a user is logged in.

Let's create `splash_screen.dart` and implement it!

[splash_screen.dart](../_snippets/flutter_firebase_login_tutorial/splash_screen.dart.md ':include')

As you can tell, this widget is super minimal and you would probably want to add some sort of image or animation in order to make it look nicer. For the sake of simplicity, we're just going to leave it as is.

Now, let's hook it up to our `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main4.dart.md ':include')

Now whenever our `AuthenticationBloc` has a `state` of `AuthenticationInitial` we will render our `SplashScreen` widget!

## Home Screen

Next, we will need to create our `HomeScreen` so that we can navigate users there once they have successfully logged in. In this case, our `HomeScreen` will allow the user to logout and also will display their current name (email).

Let's create `home_screen.dart` and get started.

[home_screen.dart](../_snippets/flutter_firebase_login_tutorial/home_screen.dart.md ':include')

`HomeScreen` is a `StatelessWidget` that requires a `name` to be injected so that it can render the welcome message. It also uses `BlocProvider` in order to access the `AuthenticationBloc` via `BuildContext` so that when a user pressed the logout button, we can add the `AuthenticationLoggedOut` event.

Now let's update our `App` to render the `HomeScreen` if the `AuthenticationState` is `AuthenticationSuccess`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main5.dart.md ':include')

## Login States

It's finally time to start working on the login flow. We'll start by identifying the different `LoginStates` that we'll have.

Create a `login` directory and create the standard bloc directory and files.

[login_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/login_bloc_dir.sh.md ':include')

Our `login/bloc/login_state.dart` should look like:

[login_state.dart](../_snippets/flutter_firebase_login_tutorial/login_state.dart.md ':include')

The states we're representing are:

`initial` is the initial state of the LoginForm.

`loading` is the state of the LoginForm when we are validating credentials

`failure` is the state of the LoginForm when a login attempt has failed.

`success` is the state of the LoginForm when a login attempt has succeeded.

We have also defined a `copyWith` and an `update` function for convenience (which we'll put to use shortly).

Now that we have the `LoginState` defined let’s take a look at the `LoginEvent` class.

## Login Events

Open up `login/bloc/login_event.dart` and let's define and implement our events.

[login_event.dart](../_snippets/flutter_firebase_login_tutorial/login_event.dart.md ':include')

The events we defined are:

`LoginEmailChanged` - notifies the bloc that the user has changed the email

`LoginPasswordChanged` - notifies the bloc that the user has changed the password

`LoginWithGooglePressed` - notifies the bloc that the user has pressed the Google Sign In button

`LoginWithCredentialsPressed` - notifies the bloc that the user has pressed the regular sign in button.

## Login Barrel File

Before we implement the `LoginBloc`, let's make sure our barrel file is done so that we can easily import all Login Bloc related files with a single import.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_barrel.dart.md ':include')

## Login Bloc

It's time to implement our `LoginBloc`. As always, we need to extend `Bloc` and define our `initialState` as well as `mapEventToState`.

[login_bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_bloc.dart.md ':include')

**Note:** We're overriding `transformEvents` in order to debounce the `LoginEmailChanged` and `LoginPasswordChanged` events so that we give the user some time to stop typing before validating the input.

We are using a `Validators` class to validate the email and password which we're going to implement next.

## Validators

Let's create `validators.dart` and implement our email and password validation checks.

[validators.dart](../_snippets/flutter_firebase_login_tutorial/validators.dart.md ':include')

There's nothing special going on here. It's just some plain old Dart code which uses regular expressions to validate the email and password. At this point, we should have a fully functional `LoginBloc` which we can hook up to the UI.

## Login Screen

Now that we're finished the `LoginBloc` it's time to create our `LoginScreen` widget which will be responsible for creating and closing the `LoginBloc` as well as providing the Scaffold for our `LoginForm` widget.

Create `login/login_screen.dart` and let's implement it.

[login_screen.dart](../_snippets/flutter_firebase_login_tutorial/login_screen.dart.md ':include')

Again, we are extending `StatelessWidget` and using a `BlocProvider` to initialize and close the `LoginBloc` as well as to make the `LoginBloc` instance available to all widgets within the sub-tree.

At this point, we need to implement the `LoginForm` widget which will be responsible for displaying the form and submission buttons in order for a user to authenticate his/her self.

## Login Form

Create `login/login_form.dart` and let's build out our form.

[login_form.dart](../_snippets/flutter_firebase_login_tutorial/login_form.dart.md ':include')

Our `LoginForm` widget is a `StatefulWidget` because it needs to maintain it's own `TextEditingControllers` for the email and password input.

We use a `BlocListener` widget in order to execute one-time actions in response to state changes. In this case, we are showing different `SnackBar` widgets in response to a pending/failure state. In addition, if the submission is successful, we use the `listener` method to notify the `AuthenticationBloc` that the user has successfully logged in.

?> **Tip:** Check out the [SnackBar Recipe](recipesfluttershowsnackbar.md) for more details.

We use a `BlocBuilder` widget in order to rebuild the UI in response to different `LoginStates`.

Whenever the email or password changes, we add an event to the `LoginBloc` in order for it to validate the current form state and return the new form state.

?> **Note:** We're using `Image.asset` to load the flutter logo from our assets directory.

At this point, you'll notice we haven't implemented `LoginButton`, `GoogleLoginButton`, or `CreateAccountButton` so we'll do those next.

## Login Button

Create `login/login_button.dart` and let's quickly implement our `LoginButton` widget.

[login_button.dart](../_snippets/flutter_firebase_login_tutorial/login_button.dart.md ':include')

There's nothing special going on here; just a `StatelessWidget` which has some styling and an `onPressed` callback so that we can have a custom `VoidCallback` whenever the button is pressed.

## Google Login Button

Create `login/google_login_button.dart` and let's get to work on our Google Sign In.

[google_login_button.dart](../_snippets/flutter_firebase_login_tutorial/google_login_button.dart.md ':include')

Again, there's not too much going on here. We have another `StatelessWidget`; however, this time we are not exposing an `onPressed` callback. Instead, we're handling the onPressed internally and adding the `LoginWithGooglePressed` event to our `LoginBloc` which will handle the Google Sign In process.

?> **Note:** We're using [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) for the cool google icon.

## Create Account Button

The last of the three buttons is the `CreateAccountButton`. Let's create `login/create_account_button.dart` and get to work.

[create_account_button.dart](../_snippets/flutter_firebase_login_tutorial/create_account_button.dart.md ':include')

In this case, again we have a `StatelessWidget` and again we're handling the `onPressed` callback internally. This time, however, we're pushing a new route in response to the button press to the `RegisterScreen`. Let's build that next!

## Register States

Just like with login, we're going to need to define our `RegisterStates` before proceeding.

Create a `register` directory and create the standard bloc directory and files.

[register_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/register_bloc_dir.sh.md ':include')

Our `register/bloc/register_state.dart` should look like:

[register_state.dart](../_snippets/flutter_firebase_login_tutorial/register_state.dart.md ':include')

?> **Note:** The `RegisterState` is very similar to the `LoginState` and we could have created a single state and shared it between the two; however, it's very likely that the Login and Register features will diverge and in most cases it's best to keep them decoupled.

Next, we'll move on to the `RegisterEvent` class.

## Register Events

Open up `register/bloc/register_event.dart` and let's implement our events.

[register_event.dart](../_snippets/flutter_firebase_login_tutorial/register_event.dart.md ':include')

?> **Note:** Again, the `RegisterEvent` implementation looks very similar to the `LoginEvent` implementation but since the two are separate features we're keeping them independent in this example.

## Register Barrel File

Again, just like with login, we need to create a barrel file to export our register bloc related files.

Open up `bloc.dart` in our `register/bloc` directory and export the three files.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_barrel.dart.md ':include')

## Register Bloc

Now, let's open `register/bloc/register_bloc.dart` and implement the `RegisterBloc`.

[register_bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_bloc.dart.md ':include')

Just as before, we need to extend `Bloc`, implement `initialState`, and `mapEventToState`. Optionally, we are overriding `transformEvents` again so that we can give users some time to finish typing before we validate the form.

Now that the `RegisterBloc` is fully functional, we just need to build out the presentation layer.

## Register Screen

Similar to the `LoginScreen`, our `RegisterScreen` will be a `StatelessWidget` responsible for initializing and closing the `RegisterBloc`. It will also provide the Scaffold for the `RegisterForm`.

Create `register/register_screen.dart` and let's implement it.

[register_screen.dart](../_snippets/flutter_firebase_login_tutorial/register_screen.dart.md ':include')

## Register Form

Next, let's create the `RegisterForm` which will provide the form fields for a user to create his/her account.

Create `register/register_form.dart` and let's build it.

[register_form.dart](../_snippets/flutter_firebase_login_tutorial/register_form.dart.md ':include')

Again, we need to manage `TextEditingControllers` for the text input so our `RegisterForm` needs to be a `StatefulWidget`. In addition, we are using `BlocListener` again in order to execute one-time actions in response to state changes such as showing `SnackBar` when the registration is pending or fails. We are also adding the `AuthenticationLoggedIn` event to the `AuthenticationBloc` if the registration was a success so that we can immediately log the user in.

?> **Note:** We're using `BlocBuilder` in order to make our UI respond to changes in the `RegisterBloc` state.

Let's build our `RegisterButton` widget next.

## Register Button

Create `register/register_button.dart` and let's get started.

[register_button.dart](../_snippets/flutter_firebase_login_tutorial/register_button.dart.md ':include')

Very similar to how we setup the `LoginButton`, the `RegisterButton` has some custom styling and exposes a `VoidCallback` so that we can handle whenever a user presses the button in the parent widget.

All that's left to do is update our `App` widget in `main.dart` to show the `LoginScreen` if the `AuthenticationState` is `AuthenticationFailure`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main6.dart.md ':include')

At this point we have a pretty solid login implementation using Firebase and we have decoupled our presentation layer from the business logic layer by using the Bloc Library.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
