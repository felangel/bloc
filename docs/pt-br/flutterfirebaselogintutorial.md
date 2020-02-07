# Tutorial Login Flutter com Firebase

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um fluxo de login do Firebase no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Setup

Começaremos criando um novo projeto Flutter

```bash
flutter create flutter_firebase_login
```

Podemos então substituir o conteúdo de `pubspec.yaml` por

```yaml
name: flutter_firebase_login
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^0.4.0+8
  google_sign_in: ^4.0.0
  firebase_auth: ^0.15.0+1
  flutter_bloc: ^3.2.0
  equatable: ^1.0.0
  meta: ^1.1.6
  font_awesome_flutter: ^8.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/
```

Observe que estamos especificando um diretório de assets para todos os assets locais de nossos aplicativos. Crie um diretório `assets` na raiz do seu projeto e adicione o recurso [flutter logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png) (que nós usaremos mais tarde).

depois instale todas as dependências

```bash
flutter packages get
```

A última coisa que precisamos fazer é seguir as [instruções de uso do firebase_auth](https://pub.dev/packages/firebase_auth#usage) para conectar nosso aplicativo ao firebase e ativar o [google_signin](https://pub.dev/packages/google_sign_in).

## User Repository

Assim como no [tutorial de login do flutter](./flutterlogintutorial.md), precisaremos criar nosso `UserRepository`, que será responsável por abstrair a implementação subjacente de como autenticamos e recuperamos as informações do usuário.

Vamos criar `user_repository.dart` e começar.

Podemos começar definindo nossa classe `UserRepository` e implementando o construtor. Você pode ver imediatamente que o `UserRepository` dependerá do FirebaseAuth e do GoogleSignIn.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();
}
```

?> **Nota:** Se o `FirebaseAuth` e/ou o GoogleSignIn não forem injetados no `UserRepository`, nós os instanciamos internamente. Isso nos permite injetar instâncias simuladas para que possamos testar facilmente o `UserRepository`.

O primeiro método que vamos implementar chamaremos `signInWithGoogle` e autenticará o usuário usando o pacote `GoogleSignIn`.

```dart
Future<FirebaseUser> signInWithGoogle() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  await _firebaseAuth.signInWithCredential(credential);
  return _firebaseAuth.currentUser();
}
```

Em seguida, implementaremos um método `signInWithCredentials` que permitirá que os usuários façam login com suas próprias credenciais usando o `FirebaseAuth`.

```dart
Future<void> signInWithCredentials(String email, String password) {
  return _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

A seguir, precisamos implementar um método `signUp` que permita aos usuários criar uma conta se optarem por não usar o Login do Google.

```dart
Future<void> signUp({String email, String password}) async {
  return await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

Precisamos implementar um método `signOut` para que possamos oferecer aos usuários a opção de efetuar logout e limpar suas informações de perfil do dispositivo.

```dart
Future<void> signOut() async {
  return Future.wait([
    _firebaseAuth.signOut(),
    _googleSignIn.signOut(),
  ]);
}
```

Por fim, precisaremos de dois métodos adicionais: `isSignedIn` e `getUser` para nos permitir verificar se um usuário já está autenticado e recuperar suas informações.

```dart
Future<bool> isSignedIn() async {
  final currentUser = await _firebaseAuth.currentUser();
  return currentUser != null;
}

Future<String> getUser() async {
  return (await _firebaseAuth.currentUser()).email;
}
```

?> **Nota:** `getUser` está retornando apenas o endereço de email do usuário atual por uma questão de simplicidade, mas podemos definir nosso próprio modelo de usuário e preenchê-lo com muito mais informações sobre o usuário em aplicativos mais complexos.

Nosso `user_repository.dart` finalizado deve ficar assim:

```dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<String> getUser() async {
    return (await _firebaseAuth.currentUser()).email;
  }
}
```

Em seguida, criaremos nosso `AuthenticationBloc`, que será responsável por manipular o `AuthenticationState` do aplicativo em resposta a `AuthenticationEvents`.

## Authentication States

Precisamos determinar como vamos gerenciar o estado de nosso aplicativo e criar os blocs necessários (componentes da lógica de negócios).

Em um nível alto, precisaremos gerenciar o estado de autenticação do usuário. O estado de autenticação de um usuário pode ser um dos seguintes:

- não inicializado - aguardando para ver se o usuário está autenticado ou não no início do aplicativo.
- autenticado - autenticado com sucesso
- não autenticado - não autenticado

Cada um desses estados terá implicações no que o usuário vê.

Por exemplo:

- se o estado de autenticação não foi inicializado, o usuário pode estar vendo uma tela inicial
- se o estado de autenticação foi autenticado, o usuário poderá ver uma tela inicial.
- se o estado de autenticação não for autenticado, o usuário poderá ver um formulário de login.

> É fundamental identificar quais serão os diferentes estados antes de mergulhar na implementação.

Agora que temos nossos estados de autenticação identificados, podemos implementar nossa classe `AuthenticationState`.

Crie uma pasta/diretório chamado `authentication_bloc` e podemos criar nossos arquivos de bloc de autenticação.

```sh
├── authentication_bloc
│   ├── authentication_bloc.dart
│   ├── authentication_event.dart
│   ├── authentication_state.dart
│   └── bloc.dart
```

?> **Dica:** Você pode usar o [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) para gerar os arquivos para você.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String displayName;

  const Authenticated(this.displayName);

  @override
  List<Object> get props => [displayName];

  @override
  String toString() => 'Authenticated { displayName: $displayName }';
}

class Unauthenticated extends AuthenticationState {}
```

?> **Nota**: O pacote [`equatable`](https://pub.dev/packages/equatable) é usado para poder comparar duas instâncias de `AuthenticationState`. Por padrão, `==` retorna true somente se os dois objetos forem da mesma instância.

?> **Nota**: O `toString` é substituído para facilitar a leitura de um `AuthenticationState` ao imprimi-lo no console ou no `Transitions`.

!> Como estamos usando o `Equatable` para nos permitir comparar diferentes instâncias do `AuthenticationState`, precisamos passar quaisquer propriedades para a superclasse. Sem o `List <Object> get props => [displayName]`, não poderemos comparar adequadamente diferentes instâncias do `Authenticated`.

## Authentication Events

Agora que temos nosso `AuthenticationState` definido, precisamos definir os `AuthenticationEvents` aos quais nosso `AuthenticationBloc` reagirá.

Nós vamos precisar:

- um evento `AppStarted` para notificar o bloc de que ele precisa verificar se o usuário está atualmente autenticado ou não.
- um evento `LoggedIn` para notificar o bloc de que o usuário efetuou login com êxito.
- um evento `LoggedOut` para notificar o bloc de que o usuário efetuou logout com sucesso.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}
```

## Authentication Barrel File

Antes de começarmos a trabalhar na implementação do `AuthenticationBloc`, exportaremos todos os arquivos do bloc de autenticação do nosso arquivo barramento `authentication_bloc/bloc.dart`. Isso nos permitirá importar o `AuthenticationBloc`,` AuthenticationEvents` e `AuthenticationState` com uma única importação posteriormente.

```dart
export 'authentication_bloc.dart';
export 'authentication_event.dart';
export 'authentication_state.dart';
```

## Authentication Bloc

Agora que temos nossos `AuthenticationState` e `AuthenticationEvents` definidos, podemos começar a trabalhar na implementação do `AuthenticationBloc`, que gerenciará a verificação e a atualização do `AuthenticationState` de um usuário em resposta a `AuthenticationEvents`.

Começaremos criando nossa classe `AuthenticationBloc`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;
```

?> **Nota**: Apenas lendo a definição da classe, já sabemos que este bloc estará convertendo `AuthenticationEvents` em `AuthenticationStates`.

?> **Nota**: Nosso `AuthenticationBloc` depende do `UserRepository`.

Podemos começar substituindo `initialState` pelo estado `AuthenticationUninitialized()`.

```dart
@override
AuthenticationState get initialState => Uninitialized();
```

Agora tudo o que resta é implementar o `mapEventToState`.

```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AppStarted) {
    yield* _mapAppStartedToState();
  } else if (event is LoggedIn) {
    yield* _mapLoggedInToState();
  } else if (event is LoggedOut) {
    yield* _mapLoggedOutToState();
  }
}

Stream<AuthenticationState> _mapAppStartedToState() async* {
  try {
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final name = await _userRepository.getUser();
      yield Authenticated(name);
    } else {
      yield Unauthenticated();
    }
  } catch (_) {
    yield Unauthenticated();
  }
}

Stream<AuthenticationState> _mapLoggedInToState() async* {
  yield Authenticated(await _userRepository.getUser());
}

Stream<AuthenticationState> _mapLoggedOutToState() async* {
  yield Unauthenticated();
  _userRepository.signOut();
}
```

Criamos funções auxiliares separadas para converter cada `AuthenticationEvent` no `AuthenticationState` adequado, a fim de manter o `mapEventToState` limpo e fácil de ler.

?> **Nota:** Estamos usando `yield *` (yield-each) em `mapEventToState` para separar os manipuladores de eventos em suas próprias funções. `yield *` insere todos os elementos da subsequência na sequência atualmente sendo construída, como se tivéssemos um rendimento individual para cada elemento.

Nosso `authentication_bloc.dart` completo deve agora ficar assim:

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final name = await _userRepository.getUser();
        yield Authenticated(name);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(await _userRepository.getUser());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.signOut();
  }
}
```

Agora que temos nosso `AuthenticationBloc` totalmente implementado, vamos trabalhar na camada de apresentação.

## App

Começaremos removendo tudo do `main.dart` e implementando nossa função principal.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}
```

Estamos agrupando todo o nosso widget `App` em um `BlocProvider` para disponibilizar o `AuthenticationBloc` para toda a árvore do widget.

?> `WidgetsFlutterBinding.ensureInitialized()` é necessário no Flutter v1.9.4 + antes de usar qualquer plug-in se o código for executado antes do runApp.

?> `BlocProvider` também controla o fechamento do `AuthenticationBloc` automaticamente, para que não precisemos fazer isso.

Em seguida, precisamos implementar nosso widget `App`.

> `App` será um `StatelessWidget` e será responsável por reagir ao estado `AuthenticationBloc` e renderizar o widget apropriado.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }
}
```

Estamos usando o `BlocBuilder` para renderizar a interface do usuário com base no estado do `AuthenticationBloc`.

Até o momento, não temos widgets para renderizar, mas voltaremos a isso assim que criarmos o `SplashScreen`, `LoginScreen` e `HomeScreen`

## Bloc Delegate

Antes de chegarmos muito longe, é sempre útil implementar nosso próprio `BlocDelegate`, que nos permite substituir `onTransition` e `onError` e nos ajudará a ver todas as mudanças de estado do bloc (transições) e erros em um só lugar!

Crie `simple_bloc_delegate.dart` e vamos implementar rapidamente nosso próprio delegado.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

Agora podemos conectar nosso `BlocDelegate` no nosso `main.dart`.

```dart
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}
```

## Splash Screen

Em seguida, precisamos criar um widget `SplashScreen` que será renderizado enquanto o nosso `AuthenticationBloc` determina se um usuário está ou não conectado.

Vamos criar `splash_screen.dart` e implementá-lo!

```dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Splash Screen')),
    );
  }
}
```

Como você pode ver, esse widget é super mínimo e você provavelmente deseja adicionar algum tipo de imagem ou animação para torná-lo mais agradável. Por uma questão de simplicidade, vamos deixar como está.

Agora, vamos ligá-lo ao nosso `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/splash_screen.dart';
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          return Container();
        },
      ),
    );
  }
}
```

Agora, sempre que nosso `AuthenticationBloc` tiver um `estado` de `Não inicializado`, renderizaremos nosso widget `SplashScreen`!

## Home Screen

Em seguida, precisaremos criar nossa `HomeScreen` para que possamos navegar pelos usuários depois que eles tiverem efetuado login com sucesso. Nesse caso, nossa `HomeScreen` permitirá que o usuário efetue logout e também exibirá seu nome atual (email).

Vamos criar `home_screen.dart` e começar.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  HomeScreen({Key key, @required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(
                LoggedOut(),
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(child: Text('Welcome $name!')),
        ],
      ),
    );
  }
}
```

O `HomeScreen` é um `StatelessWidget` que requer que um `nome` seja injetado para que possa renderizar a mensagem de boas-vindas. Ele também usa o `BlocProvider` para acessar o` AuthenticationBloc` via `BuildContext`, de modo que quando um usuário pressiona o botão de logout, podemos adicionar o evento `LoggedOut`.

Agora vamos atualizar nosso `App` para renderizar a `HomeScreen` se o `AuthenticationState` for `Authentication`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/home_screen.dart';
import 'package:flutter_firebase_login/splash_screen.dart';
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Authenticated) {
            return HomeScreen(name: state.displayName);
          }
        },
      ),
    );
  }
}
```

## Login States

Finalmente chegou a hora de começar a trabalhar no fluxo de login. Começaremos identificando os diferentes `LoginStates` que teremos.

Crie um diretório `login` e crie o diretório e os arquivos padrão do bloc.

```sh
├── lib
│   ├── login
│   │   ├── bloc
│   │   │   ├── bloc.dart
│   │   │   ├── login_bloc.dart
│   │   │   ├── login_event.dart
│   │   │   └── login_state.dart
```

Nosso `login/bloc/login_state.dart` deve se parecer com:

```dart
import 'package:meta/meta.dart';

@immutable
class LoginState {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginState({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory LoginState.empty() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory LoginState.failure() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory LoginState.success() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  LoginState update({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  LoginState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return LoginState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''LoginState {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}
```

Os estados que estamos representando são:

`vazio` é o estado inicial do LoginForm.

`loading` é o estado do LoginForm quando estamos validando credenciais

`fail` é o estado do LoginForm quando uma tentativa de login falha.

`success` é o estado do LoginForm quando uma tentativa de login é bem-sucedida.

Também definimos uma função `copyWith` e `update` por conveniência (que usaremos em breve).

Agora que temos o `LoginState` definido, vamos dar uma olhada na classe `LoginEvent`.

## Login Events

Abra `login/bloc/login_event.dart` e vamos definir e implementar nossos eventos.

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends LoginEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class Submitted extends LoginEvent {
  final String email;
  final String password;

  const Submitted({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}

class LoginWithGooglePressed extends LoginEvent {}

class LoginWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginWithCredentialsPressed({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginWithCredentialsPressed { email: $email, password: $password }';
  }
}
```

Os eventos que definimos são:

`EmailChanged` - notifica o bloc que o usuário alterou o email

`PasswordChanged` - notifica o bloc que o usuário alterou a senha

`Enviado` - notifica o bloc que o usuário enviou o formulário

`LoginWithGooglePressed` - notifica o bloc em que o usuário pressionou o botão Login do Google

`LoginWithCredentialsPressed` - notifica o bloc que o usuário pressionou o botão de logon regular.

## Login Barrel File

Antes de implementar o `LoginBloc`, vamos garantir que nosso arquivo barrel esteja pronto para que possamos importar facilmente todos os arquivos relacionados ao Login Bloc com uma única importação.

```dart
export 'login_bloc.dart';
export 'login_event.dart';
export 'login_state.dart';
```

## Login Bloc

É hora de implementar o nosso `LoginBloc`. Como sempre, precisamos estender o `Bloc` e definir o nosso `initialState` e o `mapEventToState`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/validators.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;

  LoginBloc({
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  LoginState get initialState => LoginState.empty();

  @override
  Stream<LoginState> transformEvents(
    Stream<LoginEvent> events,
    Stream<LoginState> Function(LoginEvent event) next,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      next,
    );
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<LoginState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<LoginState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _userRepository.signInWithGoogle();
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInWithCredentials(email, password);
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }
}
```

**Nota:** Nós estamos substituindo o `transformEvents` para rejeitar os eventos `EmailChanged` e `PasswordChanged`, para que possamos dar ao usuário algum tempo para parar de digitar antes de validar a entrada.

Estamos usando uma classe `Validators` para validar o email e a senha que vamos implementar a seguir.

## Validators

Vamos criar `validators.dart` e implementar nossas verificações de validação de e-mail e senha.

```dart
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }
}
```

Não há nada de especial acontecendo aqui. É apenas um código Dart antigo simples que usa expressões regulares para validar o email e a senha. Neste ponto, devemos ter um `LoginBloc` totalmente funcional, que possamos conectar à interface do usuário.

## Login Screen

Agora que terminamos o `LoginBloc`, é hora de criar o widget `LoginScreen`, que será responsável por criar e fechar o `LoginBloc`, além de fornecer o andaime para o nosso widget `LoginForm`.

Crie `login/login_screen.dart` e vamos implementá-lo.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/login/login.dart';

class LoginScreen extends StatelessWidget {
  final UserRepository _userRepository;

  LoginScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(userRepository: _userRepository),
        child: LoginForm(userRepository: _userRepository),
      ),
    );
  }
}

```

Novamente, estamos estendendo o `StatelessWidget` e usando um `BlocProvider` para inicializar e fechar o `LoginBloc`, bem como tornar a instância do `LoginBloc` disponível para todos os widgets dentro da subárvore.

Nesse ponto, precisamos implementar o widget `LoginForm`, que será responsável por exibir os botões de formulário e envio para que um usuário se autentique.

## Login Form

Crie `login/login_form.dart` e vamos criar nosso formulário.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/login/login.dart';

class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;

  LoginForm({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc _loginBloc;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Login Failure'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logging In...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset('assets/flutter_logo.png', height: 200),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isEmailValid ? 'Invalid Email' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isPasswordValid ? 'Invalid Password' : null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        LoginButton(
                          onPressed: isLoginButtonEnabled(state)
                              ? _onFormSubmitted
                              : null,
                        ),
                        GoogleLoginButton(),
                        CreateAccountButton(userRepository: _userRepository),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
```

Nosso widget `LoginForm` é um `StatefulWidget` porque precisa manter seu próprio `TextEditingControllers` para a entrada de e-mail e senha.

Utilizamos um widget `BlocListener` para executar ações únicas em resposta a alterações de estado. Neste caso, estamos mostrando diferentes widgets `SnackBar` em resposta a um estado pendente / falha. Além disso, se o envio for bem-sucedido, usamos o método `listener` para notificar o `AuthenticationBloc` de que o usuário efetuou login com êxito.

?> **Dica:** Confira a [Receita do BlocListener](recipesbloclistener.md) para mais detalhes.

Usamos um widget `BlocBuilder` para reconstruir a interface do usuário em resposta a diferentes `LoginStates`.

Sempre que o email ou a senha são alterados, adicionamos um evento ao `LoginBloc` para validar o estado atual do formulário e retornar o novo estado do formulário.

?> **Nota:** Estamos usando o `Image.asset` para carregar o logotipo flutter do nosso diretório de assets.

Neste ponto, você notará que não implementamos `LoginButton`,`GoogleLoginButton` ou `CreateAccountButton`, portanto faremos isso a seguir.

## Botão de Login

Crie `login/login_button.dart` e vamos implementar rapidamente nosso widget `LoginButton`.

```dart
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback _onPressed;

  LoginButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text('Login'),
    );
  }
}
```

Não há nada de especial acontecendo aqui; apenas um `StatelessWidget` que possui algum estilo e um retorno de chamada `onPressed`, para que possamos ter um `VoidCallback` personalizado sempre que o botão for pressionado.

## Botão Login com Google 

Crie `login/google_login_button.dart` e vamos trabalhar no nosso login no Google.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      icon: Icon(FontAwesomeIcons.google, color: Colors.white),
      onPressed: () {
        BlocProvider.of<LoginBloc>(context).add(
          LoginWithGooglePressed(),
        );
      },
      label: Text('Sign in with Google', style: TextStyle(color: Colors.white)),
      color: Colors.redAccent,
    );
  }
}
```

Novamente, não há muita coisa acontecendo aqui. Temos outro `StatelessWidget`; no entanto, desta vez não estamos expondo um retorno de chamada `onPressed`. Em vez disso, lidamos com o onPressed internamente e adicionamos o evento `LoginWithGooglePressed` ao nosso `LoginBloc`, que tratará do processo de login do Google.

?> **Nota:** Estamos usando [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) para o ícone legal do Google.

## Botão Criar Conta

O último dos três botões é o `CreateAccountButton`. Vamos criar `login/create_account_button.dart` e começar a trabalhar.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/register/register.dart';

class CreateAccountButton extends StatelessWidget {
  final UserRepository _userRepository;

  CreateAccountButton({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Create an Account',
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return RegisterScreen(userRepository: _userRepository);
          }),
        );
      },
    );
  }
}
```

Nesse caso, novamente temos um `StatelessWidget` e novamente lidamos com o retorno de chamada `onPressed` internamente. Desta vez, no entanto, estamos empurrando uma nova rota em resposta ao pressionar o botão para `RegisterScreen`. Vamos construir isso a seguir!

## Register States

Assim como no login, precisamos definir nossos `RegisterStates` antes de prosseguir.

Crie um diretório `register` e crie o diretório e os arquivos padrão do bloc.

```sh
├── lib
│   ├── register
│   │   ├── bloc
│   │   │   ├── bloc.dart
│   │   │   ├── register_bloc.dart
│   │   │   ├── register_event.dart
│   │   │   └── register_state.dart
```

Nosso `register/bloc/register_state.dart` deve se parecer com:

```dart
import 'package:meta/meta.dart';

@immutable
class RegisterState {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  bool get isFormValid => isEmailValid && isPasswordValid;

  RegisterState({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory RegisterState.empty() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.loading() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.failure() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory RegisterState.success() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  RegisterState update({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  RegisterState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return RegisterState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''RegisterState {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}
```

?> **Nota:** O `RegisterState` é muito semelhante ao `LoginState` e poderíamos ter criado um único estado e o compartilhado entre os dois; no entanto, é muito provável que os recursos de login e registro sejam divergentes e, na maioria dos casos, é melhor mantê-los dissociados.

Em seguida, passaremos para a classe `RegisterEvent`.

## Register Events

Abra `register/bloc/register_event.dart` e vamos implementar nossos eventos.

```dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends RegisterEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends RegisterEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class Submitted extends RegisterEvent {
  final String email;
  final String password;

  const Submitted({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}
```

?> **Nota:** Novamente, a implementação do `RegisterEvent` se parece muito com a implementação do `LoginEvent`, mas como os dois são recursos separados, nós os mantemos independentes neste exemplo.

## Arquivo Barrel Register

Novamente, assim como no login, precisamos criar um arquivo barrel para exportar nossos arquivos relacionados ao bloc de registros.

Abra `bloc.dart` em nosso diretório `register/bloc` e exporte os três arquivos.

```dart
export 'register_bloc.dart';
export 'register_event.dart';
export 'register_state.dart';
```

## Register Bloc

Agora, vamos abrir `register/bloc/register_bloc.dart` e implementar o `RegisterBloc`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/register/register.dart';
import 'package:flutter_firebase_login/validators.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository _userRepository;

  RegisterBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  RegisterState get initialState => RegisterState.empty();

  @override
  Stream<RegisterState> transformEvents(
    Stream<RegisterEvent> events,
    Stream<RegisterState> Function(RegisterEvent event) next,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      next,
    );
  }

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.email, event.password);
    }
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<RegisterState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<RegisterState> _mapFormSubmittedToState(
    String email,
    String password,
  ) async* {
    yield RegisterState.loading();
    try {
      await _userRepository.signUp(
        email: email,
        password: password,
      );
      yield RegisterState.success();
    } catch (_) {
      yield RegisterState.failure();
    }
  }
}
```

Assim como antes, precisamos estender o `Bloc`, implementar `initialState` e `mapEventToState`. Opcionalmente, estamos substituindo o `transformEvents` novamente, para que possamos dar aos usuários algum tempo para terminar de digitar antes de validar o formulário.

Agora que o `RegisterBloc` está totalmente funcional, precisamos construir a camada de apresentação.

## Register Screen

Semelhante ao `LoginScreen`, nosso `RegisterScreen` será um `StatelessWidget` responsável por inicializar e fechar o `RegisterBloc`. Ele também fornecerá o andaime para o `RegisterForm`.

Crie `register/register_screen.dart` e vamos implementá-lo.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/register/register.dart';

class RegisterScreen extends StatelessWidget {
  final UserRepository _userRepository;

  RegisterScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(userRepository: _userRepository),
          child: RegisterForm(),
        ),
      ),
    );
  }
}

```

## Register Form

Em seguida, vamos criar o `RegisterForm` que fornecerá os campos de formulário para um usuário criar sua conta.

Crie `register/register_form.dart` e vamos construí-lo.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/register/register.dart';

class RegisterForm extends StatefulWidget {
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterBloc _registerBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registering...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
          Navigator.of(context).pop();
        }
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registration Failure'),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autovalidate: true,
                    validator: (_) {
                      return !state.isEmailValid ? 'Invalid Email' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    autovalidate: true,
                    validator: (_) {
                      return !state.isPasswordValid ? 'Invalid Password' : null;
                    },
                  ),
                  RegisterButton(
                    onPressed: isRegisterButtonEnabled(state)
                        ? _onFormSubmitted
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _registerBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _registerBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.add(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
```

Novamente, precisamos gerenciar `TextEditingControllers` para a entrada de texto, para que nosso `RegisterForm` precise ser um `StatefulWidget`. Além disso, estamos usando o BlocListener novamente para executar ações únicas em resposta a alterações de estado, como mostrar o SnackBar quando o registro está pendente ou falha. Também estamos adicionando o evento `LoggedIn` ao `AuthenticationBloc` se o registro foi bem-sucedido, para que possamos logar imediatamente o usuário.

?> **Nota:** Estamos usando o `BlocBuilder` para fazer com que nossa interface do usuário responda às alterações no estado `RegisterBloc`.

Vamos construir o nosso widget `RegisterButton` a seguir.

## Botão Registrar

Crie `register/register_button.dart` e vamos começar.

```dart
import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback _onPressed;

  RegisterButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text('Register'),
    );
  }
}
```

Muito parecido com o modo como configuramos o `LoginButton`, o `RegisterButton` possui um estilo personalizado e expõe um `VoidCallback` para que possamos lidar sempre que um usuário pressionar o botão no widget pai.

Tudo o que resta a fazer é atualizar o widget `App` no `main.dart` para mostrar a `LoginScreen` se o `AuthenticationState` for `Unauthenticated`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/home_screen.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_firebase_login/splash_screen.dart';
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Unauthenticated) {
            return LoginScreen(userRepository: _userRepository);
          }
          if (state is Authenticated) {
            return HomeScreen(name: state.displayName);
          }
        },
      ),
    );
  }
}
```

Nesse ponto, temos uma implementação de login bastante sólida usando o Firebase e dissociamos nossa camada de apresentação da camada de lógica de negócios usando a Biblioteca de Bloc.

O código fonte completo deste exemplo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
