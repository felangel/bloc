# Tutorial Login Flutter  

![intermediário](https://img.shields.io/badge/level-intermediate-orange.svg)

> No tutorial a seguir, criaremos um fluxo de login no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Setup

Começaremos criando um novo projeto Flutter

```bash
flutter create flutter_login
```

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por

```yaml
name: flutter_login
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  meta: ^1.1.6
  equatable: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

e instale todas as nossas dependências

```bash
flutter packages get
```

## Repositório User

Vamos precisar criar um `UserRepository` que nos ajude a gerenciar os dados de um usuário.

```dart
class UserRepository {
  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return 'token';
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return false;
  }
}
```

?> **Nota**: Nosso repositório de usuários está apenas mockando todas as diferentes implementações por uma questão de simplicidade, mas em um aplicativo real você pode injetar um [HttpClient] (https://pub.dev/packages/http), além de algo como [Flutter Secure Storage ](https://pub.dev/packages/flutter_secure_storage) para solicitar tokens e ler / gravá-los no keystore / keychain.

## Authentication States

Em seguida, precisaremos determinar como gerenciaremos o estado de nosso aplicativo e criaremos os blocs necessários (componentes da lógica de negócios).

Em um nível alto, precisaremos gerenciar o estado de autenticação do usuário. O estado de autenticação de um usuário pode ser um dos seguintes:

- não inicializado - aguardando para ver se o usuário está autenticado ou não no início do aplicativo.
- carregando - esperando para persistir / excluir um token
- autenticado - autenticado com sucesso
- não autenticado - não autenticado

Cada um desses estados terá implicações no que o usuário vê.

Por exemplo:

- se o estado de autenticação não foi inicializado, o usuário pode estar vendo uma tela inicial.
- se o estado de autenticação estava carregando, o usuário pode estar vendo um indicador de progresso.
- se o estado de autenticação foi autenticado, o usuário poderá ver uma tela inicial.
- se o estado de autenticação não for autenticado, o usuário poderá ver um formulário de login.

> É fundamental identificar quais serão os diferentes estados antes de mergulhar na implementação.

Agora que temos nossos estados de autenticação identificados, podemos implementar nossa classe `AuthenticationState`.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}
```

?> **Nota**: O pacote [`equatable`](https://pub.dev/packages/equatable) é usado para poder comparar duas instâncias de `AuthenticationState`. Por padrão, `==` retorna true somente se os dois objetos forem da mesma instância.

## Authentication Events

Agora que temos nosso `AuthenticationState` definido, precisamos definir os `AuthenticationEvents` aos quais nosso `AuthenticationBloc` reagirá.

Nós vamos precisar:

- um evento `AppStarted` para notificar o bloc de que ele precisa verificar se o usuário está atualmente autenticado ou não.
- um evento `LoggedIn` para notificar o bloc de que o usuário efetuou login com êxito.
- um evento `LoggedOut` para notificar o bloc de que o usuário efetuou logout com sucesso.

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {}
```

?> **Nota**: o pacote `meta` é usado para anotar os parâmetros `AuthenticationEvent` como `@required`. Isso fará com que o analisador dart avise os desenvolvedores se eles não fornecerem os parâmetros necessários.

## Authentication Bloc

Agora que temos nossos `AuthenticationState` e `AuthenticationEvents` definidos, podemos começar a trabalhar na implementação do `AuthenticationBloc`, que gerenciará a verificação e a atualização do `AuthenticationState` de um usuário em resposta a `AuthenticationEvents`.

Começaremos criando nossa classe `AuthenticationBloc`.

```dart
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository}): assert(userRepository != null);
}
```

?> **Nota**: Apenas lendo a definição da classe, já sabemos que este bloc estará convertendo `AuthenticationEvents` em `AuthenticationStates`.

?> **Nota**: Nosso `AuthenticationBloc` depende do `UserRepository`.

Podemos começar substituindo `initialState` pelo estado `AuthenticationUninitialized()`.

```dart
@override
AuthenticationState get initialState => AuthenticationUninitialized();
```

Agora tudo o que resta é implementar o `mapEventToState`.

```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AppStarted) {
    final bool hasToken = await userRepository.hasToken();

    if (hasToken) {
      yield AuthenticationAuthenticated();
    } else {
      yield AuthenticationUnauthenticated();
    }
  }

  if (event is LoggedIn) {
    yield AuthenticationLoading();
    await userRepository.persistToken(event.token);
    yield AuthenticationAuthenticated();
  }

  if (event is LoggedOut) {
    yield AuthenticationLoading();
    await userRepository.deleteToken();
    yield AuthenticationUnauthenticated();
  }
}
```

Ótimo! Nosso `AuthenticationBloc` final deve se parecer com

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool hasToken = await userRepository.hasToken();

      if (hasToken) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.token);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}
```

Agora que temos nosso `AuthenticationBloc` totalmente implementado, vamos trabalhar na camada de apresentação.

## Splash Page

A primeira coisa que precisamos é de um widget `SplashPage`, que servirá como nossa tela inicial, enquanto o nosso `AuthenticationBloc` determina se um usuário está ou não conectado.

```dart
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
```

## Home Page

Em seguida, precisaremos criar nossa `HomePage` para que possamos navegar pelos usuários lá depois que eles fizerem login com êxito.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: Center(
            child: RaisedButton(
          child: Text('logout'),
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
          },
        )),
      ),
    );
  }
}
```

?> **Nota**: Esta é a primeira classe em que estamos usando o `flutter_bloc`. Entraremos em breve em `BlocProvider.of<AuthenticationBloc>(context)`, mas por enquanto sabemos que ele permite que nossa `HomePage` acesse o nosso `AuthenticationBloc`.

?> **Nota**: Estamos adicionando um evento `LoggedOut` ao nosso `AuthenticationBloc` quando um usuário pressiona o botão logout.

Em seguida, precisamos criar um `LoginPage` e `LoginForm`.

Como o `LoginForm` precisará lidar com a entrada do usuário (botão de login pressionado) e precisará ter alguma lógica de negócio (obtendo um token para um determinado nome de usuário/senha), precisaremos criar um `LoginBloc`.

Assim como fizemos no `AuthenticationBloc`, precisaremos definir o `LoginState` e `LoginEvents`. Vamos começar com "LoginState".

## Login States

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'LoginFailure { error: $error }';
}
```

`LoginInitial` é o estado inicial do LoginForm.

`LoginLoading` é o estado do LoginForm quando estamos validando credenciais

`LoginFailure` é o estado do LoginForm quando uma tentativa de login falha.

Agora que temos o `LoginState` definido, vamos dar uma olhada na classe `LoginEvent`.

## Login Events

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}
```

O `LoginButtonPressed` será adicionado quando um usuário pressionar o botão de login. Ele notificará o `LoginBloc` de que precisa solicitar um token para as credenciais fornecidas.

Agora podemos implementar nosso `LoginBloc`.

## Login Bloc

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(token: token));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
```

?> **Nota**: O `LoginBloc` depende do `UserRepository` para autenticar um usuário com um nome de usuário e senha.

?> **Nota**: O `LoginBloc` depende do `AuthenticationBloc` para atualizar o AuthenticationState quando um usuário inserir credenciais válidas.

Agora que temos o nosso `LoginBloc`, podemos começar a trabalhar no `LoginPage` e `LoginForm`.

## Login Page

O widget `LoginPage` servirá como nosso widget Container e fornecerá as dependências necessárias para o widget `LoginForm` (`LoginBloc` e `AuthenticationBloc`).

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginForm(),
      ),
    );
  }
}
```

?> **Nota**: `LoginPage` é um `StatelessWidget`. O widget `LoginPage` usa o widget `BlocProvider` para criar, fechar e fornecer o `LoginBloc` para a subárvore.

?> **Nota**: Estamos usando o `UserRepository` injetado para criar nosso `LoginBloc`.

?> **Nota**: Estamos usando o `BlocProvider.of<AuthenticationBloc>(context)` novamente para acessar o `AuthenticationBloc` no `LoginPage`.

Em seguida, vamos em frente e crie nosso `LoginForm`.

## Login Form

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/login/login.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'username'),
                  controller: _usernameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'password'),
                  controller: _passwordController,
                  obscureText: true,
                ),
                RaisedButton(
                  onPressed:
                      state is! LoginLoading ? _onLoginButtonPressed : null,
                  child: Text('Login'),
                ),
                Container(
                  child: state is LoginLoading
                      ? CircularProgressIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

?> **Nota**: Nosso `LoginForm` usa o widget `BlocBuilder` para que possa ser reconstruído sempre que houver um novo `LoginState`. O BlocBuilder é um widget do Flutter que requer uma função do Bloc e do construtor. O BlocBuilder trata da construção do widget em resposta a novos estados. O `BlocBuilder` é muito semelhante ao` StreamBuilder`, mas possui uma API mais simples para reduzir a quantidade de código padrão necessário e várias otimizações de desempenho.

Não há muito mais acontecendo no widget `LoginForm`, então vamos continuar criando o nosso indicador de carregamento.

## Loading Indicator

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}
```

Agora chegou a hora de juntar tudo e criar o widget principal do aplicativo em `main.dart`.

## Juntando tudo

```dart
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';
import 'package:flutter_login/common/common.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();
  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return SplashPage();
          }
          if (state is AuthenticationAuthenticated) {
            return HomePage();
          }
          if (state is AuthenticationUnauthenticated) {
            return LoginPage(userRepository: userRepository);
          }
          if (state is AuthenticationLoading) {
            return LoadingIndicator();
          }
        },
      ),
    );
  }
}
```

?> **Nota**: Novamente, estamos usando o `BlocBuilder` para reagir às alterações no `AuthenticationState`, para que possamos mostrar ao usuário o `SplashPage`, `LoginPage`, `HomePage` ou `LoadingIndicator` com base no atual AuthenticationState.

?> **Nota**: Nosso aplicativo está envolto em um `BlocProvider`, que torna nossa instância do `AuthenticationBloc` disponível para toda a subárvore do widget. O `BlocProvider` é um widget Flutter que fornece um bloc para seus filhos via` BlocProvider.of (context) `. Ele é usado como um widget de injeção de dependência (DI) para que uma única instância de um bloc possa ser fornecida a vários widgets em uma subárvore.

Agora o `BlocProvider.o<AuthenticationBloc>(context)` em nosso widget `HomePage` e `LoginPage` deve fazer sentido.

Como empacotamos nosso `App` dentro de um `BlocProvider<AuthenticationBloc>`, podemos acessar a instância do nosso `AuthenticationBloc` usando o método estático `BlocProvider.of<AuthenticationBloc>(BuildContext contexto)` de qualquer lugar na subárvore.

Neste ponto, temos uma implementação de login bastante sólida e dissociamos nossa camada de apresentação da camada de lógica de negócios usando o Bloc.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
