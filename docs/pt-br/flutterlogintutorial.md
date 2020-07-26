# Flutter Login Tutorial

![intermediário](https://img.shields.io/badge/level-intermediate-orange.svg)

> No tutorial a seguir, nós iremos construir um fluxo de Login no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Setup do Projeto

Nós iremos começar criando um novo projeto Flutter

```sh
flutter create flutter_login
```

Depois, nós podemos instalar todas nossas dependências

```sh
flutter packages get
```

## Repositório de Autenticação

A primeira coia que iremos fazer é criar um pacote `authentication_repository` que será responsável por gerenciar o domínio de autenticação.

Vamos começar criando um diretório `packages/authentication_repository` na raíz do projeto que irá conter todos os pacotes internos.

Em alto nível, a estrutura do diretório se parecerá com essa:

```sh
├── android
├── ios
├── lib
├── packages
│   └── authentication_repository
└── test
```

Depois, nós podemos criar um `pubspec.yaml` para o pacote `authentication_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/pubspec.yaml ':include')

?> **Nota**: `package:authentication_repository` será um pacote Dart puro e para simplificar nós teremos apenas uma dependência sobre o [pacote:meta](https://pub.dev/packages/meta) para alguma anotações uteis.

Seguindo, nós precisamos implementar a classe `AuthenticationRepository` em sí que estará em `lib/src/authentication_repository.dart`.

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/src/authentication_repository.dart ':include')

O `AuthenticationRepository` expõe uma `Stream` de atualizações do `AuthenticationStatus` que será usada para notificar a aplicação quando o usuário logar ou deslogar.

Além disso, terão os esboços dos métodos `logIn` e `logOut` para simplificar mas que podem ser facilmente estendidos para autenticar com o `FirebaseAuth` por exemplo ou algum outro provedor de autenticação.

?> **Nota**: Uma vez que estamos mantendo o `StreamController` internamente, o método `dispose` é exposto de modo que o controller pode ser fechado quando ele não for mais necessário.

Por último, nós precisamos criar `lib/authentication_repository.dart` que conterá as exportações públicas:

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/authentication_repository.dart ':include')

E é isso para o `AuthenticationRepository`, agora iremos trabalhar no `UserRepository`.

## Repositório do Usuário

Assim como o `AuthenticationRepository`, nós iremos criar um pacote `user_repository` dentro do diretório `packages`.

```sh
├── android
├── ios
├── lib
├── packages
│   ├── authentication_repository
│   └── user_repository
└── test
```

Depois, vamos criar o `pubspec.yaml` para o `user_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/pubspec.yaml ':include')

O `user_repository` será responsável pelo domínio do usuário e irá expor as APIs para interagir com o usuário atual.

A primeira coisa que iremos definir é o modelo de usuário em `lib/src/models/user.dart`:

[user.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/user.dart ':include')

Para simplificar, um usuários terá apenas a propriedade `id` mas na prática nós podemos ter propriedades adicionais como `firstName`, `lastName`, `avatarUrl`, etc...

?> **Nota**: [package:equatable](https://pub.dev/packages/equatable) é usado para habilitar a comparação de valores do objeto `User`.

Seguindo, nós podemos criar um `models.dart` em `lib/src/models` que irá exportar todos os modelos assim nós podemos usar um único import para importar múltiplos modelos.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/models.dart ':include')

Agora que os modelos foram definidos, nós podemos implementar a classe `UserRepository`.

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/user_repository.dart ':include')

Para esse simples exemplo, o `UserRepository` expões um único método `getUser` que irá recuperar o usuário atual. Aqui nós estamos esboçando mas em prática aqui é onde nós podemos fazer uma consulta do usuário atual no backend.

Quase finalizado com o pacote `user_repository` -- a única coisa que falta é criar o arquivo `user_repository.dart` em `lib` que define as exportações públicas:

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/user_repository.dart ':include')

Agora que nós já terminamos com os pacotes `authentication_repository` e `user_repository`, nós podemos focar na aplicação Flutter.

## Instalando as Dependências

Vamos começar atualizando o `pubspec.yaml` gerado na raíz do nosso projeto:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/pubspec.yaml ':include')

Nós podemos instalar as dependências rodando:

```sh
flutter packages get
```

## Authentication Bloc

The `AuthenticationBloc` will be responsible to reacting to changes in the authentication state (exposed by the `AuthenticationRepository`) and will emit states we can react to in the presentation layer.

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

- `AuthenticationStatusChanged`: notifies the bloc of a change to the user's AuthenticationStatus
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

Next, `mapEventToState` handles transforming the incoming `AuthenticationEvent` instances into new `AuthenticationState` instances.

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

We are using [package:formz](https://pub.dev/packages/formz) to create reusable and standard models the the `username` and `password`.

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

?> **Note**: `context.repository` is used to lookup the instance of `AuthenticationRepository` via the `BuildContext`.

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

The `HomePage` can access the current user's ID via `context.bloc<AuthenticationBloc>().state.user.id` and displays it via a `Text` widget. In addition, when the logout button is tapped, an `AuthenticationLogoutRequested` event is added to the `AuthenticationBloc`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/home/view/home_page.dart ':include')

?> **Note**: `context.bloc<AuthenticationBloc>().state.user.id` is a one time look-up and does not subscribe for updates.

At this point we have a pretty solid login implementation and we have decoupled our presentation layer from the business logic layer by using Bloc.

O código fonte completo para este exemplo (incluindo os testes unitários e de widget) pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
