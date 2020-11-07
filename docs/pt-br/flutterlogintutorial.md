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

O `AuthenticationBloc` será responsável por reagir as mudanças no estado da autenticação (exposto pelo `AuthenticationRepository`) e irá emitir estados que nós podemos reagir para a camada de apresentação.

A implementação do `AuthenticationBloc` está dento de `lib/authentication` porque nós tratamos authentication como uma funcionalidade na nossa camada de aplicação.

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

?> **Dica**: Use a [Extensão do VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou o [Plugin doIntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc) para criar blocs automaticamente.

### authentication_event.dart

> instâncias de `AuthenticationEvent` serão as entradas para o `AuthenticationBloc` e serão processadas e usadas para emitir novas instâncias de `AuthenticationState`.

Nessa aplicação, o `AuthenticationBloc` estará reagindo a dois diferentes eventos:

- `AuthenticationStatusChanged`: notifica o bloc de uma mudança para os AuthenticationStatus do usuário
- `AuthenticationLogoutRequested`: notifica o bloc de uma requisição de logout

[authentication_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_event.dart ':include')

Seguindo, vamos dar uma olhada em `AuthenticationState`.

### authentication_state.dart

> instâncias de `AuthenticationState` serão a saída do `AuthenticationBloc` e serão consumidos pela cama camada de apresentação.

A classe `AuthenticationState` tem três construtores nomeados:

- `AuthenticationState.unknown()`: o estado padrão que indica que o bloc ainda não conhece se o usuário atual está autenticado ou não.

- `AuthenticationState.authenticated()`: o estado que indicia que o usuário atual está autenticado.

- `AuthenticationState.unauthenticated()`: o estado que indica que o usuário atual não está autenticado.

[authentication_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_state.dart ':include')

Now that we have seen the `AuthenticationEvent` and `AuthenticationState` implementations let's take a look at `AuthenticationBloc`.

### authentication_bloc.dart

> O `AuthenticationBloc` gerencia o estado de autenticação da aplicação que é usado para determinar coisas como se deve ou não iniciar o usuário na página de login ou na página inicial.

[authentication_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_bloc.dart ':include')

O `AuthenticationBloc` tem uma dependência de ambos `AuthenticationRepository` e `UserRepository` e define o estado inicial como `AuthenticationState.unknown()`.

No corpo do construtor, o `AuthenticationBloc` assina o `status` da stream do `AuthenticationRepository` e adiciona internamente um evento `AuthenticationStatusChanged` em resposta a um novo`AuthenticationStatus`.

!> O `AuthenticationBloc` sobrescreve `close` para que possa descartar ambos o `StreamSubscription` como também o `AuthenticationRepository`.

Em seguida, `mapEventToState` lida transformado as instâncias chegadas do `AuthenticationEvent` em novas instâncias do `AuthenticationState`.

Quando um evento `AuthenticationStatusChanged` é adicionado se o estado associado é `AuthenticationStatus.authenticated`, o `AuthenticationBloc` irá consultar o usuário usando o `UserRepository`.

## main.dart

Em seguida, nós podemos substituir o `main.dart` padrão com:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/main.dart ':include')

?> **Nota**: Nós estamos injetando uma instância única do `AuthenticationRepository` e `UserRepository` no widget `App` (que nós trataremos em seguida).

## App

`app.dart` irá conter o widget raíz `App` para toda a aplicação.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/app.dart ':include')

?> **Nota**: `app.dart` é dividido em duas partes `App` e `AppView`. `App` é responsável por criar/prover o `AuthenticationBloc` que será consumido pelo `AppView`. Esse desacoplamento irá nos possibilitar testar facilmente ambos widgets `App` e `AppView` mais tarde.

?> **Nota**: `RepositoryProvider` é usado para prover uma única instância do `AuthenticationRepository` para toda a aplicação que virá a ser útil mais tarde.

`AppView` é um `StatefulWidget` porque ele mantém uma `GlobalKey` que é usada para acessar o `NavigatorState`. Por padrão, o `AppView` irá renderizar o `SplashPage` (que veremos depois) e usa o `BlocListener` para navegar para diferentes páginas baseado nas mudanças do `AuthenticationState`.

## Splash

> A funcionalidade splash conterá apenas uma simples view que será renderizada quando o app é inicializado enquanto o app determina se o usuário é autenticado.

```sh
lib
└── splash
    ├── splash.dart
    └── view
        └── splash_page.dart
```

[splash_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/splash/view/splash_page.dart ':include')

?> **Dica**: `SplashPage` expõe uma `Route` estática que que facilita a navegação para sua rota via `Navigator.of(context).push(SplashPage.route())`;

## Login

> A funcionalidade login contém um `LoginPage`, `LoginForm` e `LoginBloc` e permite aos usuários entrarem com o nome de usuário e senha para logar na aplicação.

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

### Modelos de Login

Nós estamos usando [package:formz](https://pub.dev/packages/formz) para criar modelos reusáveis e padronizados do `username` e `password`.

#### Nome do Usuário

[username.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/username.dart ':include')

Para simplificar, nós estamos apenas validando o nome de usuário para garantir que ele não está vazio mas na prática você pode impor o uso de caracteres especiais, tamanho, etc...

#### Senha

[password.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/password.dart ':include')

Novamente, nós estamos realizando apenas uma verificação simples para garantir que a senha não esteja vazia.

#### Modelos Barrel

Assim como antes, existe um barrel `models.dart` para facilitar a importação dos modelos `Username` e `Password` com somente um import.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/models.dart ':include')

### Login Bloc

> O `LoginBloc` gerencia o estado do `LoginForm` e cuida das validações dos inputs de nome de usuário e senha como também o estado do formulário.

#### login_event.dart

Nessa aplicação há três diferentes tipos de `LoginEvent`:

- `LoginUsernameChanged`: notifica o bloc que o nome de usuário foi modificado.
- `LoginPasswordChanged`: notifica o bloc que a senha foi modificada.
- `LoginSubmitted`: notifica o bloc que o formulário foi submetido.

[login_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_event.dart ':include')

#### login_state.dart

O `LoginState` irá conter o estado do formulário como também os estados dos inputs de nome do usuário e senha.

[login_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_state.dart ':include')

?> **Nota**: Os modelos de `Username` e `Password` são usados como parte do `LoginState` e o status também faz parte do [pacote:formz](https://pub.dev/packages/formz).

#### login_bloc.dart

> O `LoginBloc` é responsável por reagir as interações do usuário no `LoginForm` e controla a validação e submissão do formulário.

[login_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_bloc.dart ':include')

O `LoginBloc` tem uma dependência do `AuthenticationRepository` porque quando o formulário é submetido, ele chama o `logIn`. O estado inicial do bloc é `puro` significando que nem os input e nem o formulário foi tocado ou teve interação.

Sempre que o `username` ou `password` mudarem, o bloc irá criar uma versão suja dos modelos `Username`/`Password` e atualizar o status através da API `Formz.validate`.

Quando o evento `LoginSubmitted` é adicionado, se o status do fomulário for válido, o bloc fara uma chamada para `logIn` e atualizará o status baseado no resultado da requisição.

A seguir iremos dar uma olhada em `LoginPage` e `LoginForm`.

### Página de Login

> O `LoginPage` é responsável por expor a `Route` como também criar e prover o `LoginBloc` para o `LoginForm`.

[login_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_page.dart ':include')

?> **Nota**: `context.read` é usado para procurar acima uma instância do `AuthenticationRepository` através do `BuildContext`.

### Formulário de Login

> O `LoginForm` controla as notificações de `LoginBloc` dos eventos do usuário e também responde as mudanças de estado usando o `BlocBuilder` e `BlocListener`.

[login_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_form.dart ':include')

O `BlocListener` é usado para mostrar uma `SnackBar` se a submissão do login falhar. Em adição, `BlocBuilder` widgets são usado para envolver cada um dos `TextField` widgets e fazer uso da propriedade `buildWhen` para otimizar as reconstruções. O callback `onChanged` é usado para notificar o `LoginBloc` das mudanças no nome de usuário/senha.

O widget `_LoginButton` somente é habilitado se o status do formulário for válido e um `CircularProgressIndicator` é mostrado em seu lugar enquanto o formulário está sendo submetido.

## Inicio

> Após uma requisição de sucesso de `logIn`, o estado do `AuthenticationBloc` mudará para `authenticated` e o usuário será redirecionado para a `HomePage` onde nós mostramos o `id` do usuário como também um botão para sair.

```sh
├── lib
│   ├── home
│   │   ├── home.dart
│   │   └── view
│   │       └── home_page.dart
```

### Página Inicial

A `HomePage` pode acessar o ID do usuário atual através do `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` e mostrá-lo usando um widget `Text`. Além do mais, quando o botão de sair é pressionado, um evento de `AuthenticationLogoutRequested` é adicionado ao `AuthenticationBloc`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/home/view/home_page.dart ':include')

?> **Nota**: o `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` irá disparar atualizações se o user id mudar.

Nes ponto temos uma implementação sólida de login e nós desacoplamos nossa camada de apresentação da camada com as regras de negócio usando o Bloc.

O código fonte completo para este exemplo (incluindo os testes unitários e de widget) pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
