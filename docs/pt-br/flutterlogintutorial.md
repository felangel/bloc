# Tutorial Login Flutter

![intermediário](https://img.shields.io/badge/level-intermediate-orange.svg)

> No tutorial a seguir, criaremos um fluxo de login no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Setup

Começaremos criando um novo projeto Flutter

[script](../_snippets/flutter_login_tutorial/flutter_create.sh.md ':include')

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por

[pubspec.yaml](../_snippets/flutter_login_tutorial/pubspec.yaml.md ':include')

e instale todas as nossas dependências

[script](../_snippets/flutter_login_tutorial/flutter_packages_get.sh.md ':include')

## Repositório User

Vamos precisar criar um `UserRepository` que nos ajude a gerenciar os dados de um usuário.

[user_repository.dart](../_snippets/flutter_login_tutorial/user_repository.dart.md ':include')

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

[authentication_state.dart](../_snippets/flutter_login_tutorial/authentication_state.dart.md ':include')

?> **Nota**: O pacote [`equatable`](https://pub.dev/packages/equatable) é usado para poder comparar duas instâncias de `AuthenticationState`. Por padrão, `==` retorna true somente se os dois objetos forem da mesma instância.

## Authentication Events

Agora que temos nosso `AuthenticationState` definido, precisamos definir os `AuthenticationEvents` aos quais nosso `AuthenticationBloc` reagirá.

Nós vamos precisar:

- um evento `AuthenticationStarted` para notificar o bloc de que ele precisa verificar se o usuário está atualmente autenticado ou não.
- um evento `AuthenticationLoggedIn` para notificar o bloc de que o usuário efetuou login com êxito.
- um evento `AuthenticationLoggedOut` para notificar o bloc de que o usuário efetuou logout com sucesso.

[authentication_event.dart](../_snippets/flutter_login_tutorial/authentication_event.dart.md ':include')

?> **Nota**: o pacote `meta` é usado para anotar os parâmetros `AuthenticationEvent` como `@required`. Isso fará com que o analisador dart avise os desenvolvedores se eles não fornecerem os parâmetros necessários.

## Authentication Bloc

Agora que temos nossos `AuthenticationState` e `AuthenticationEvents` definidos, podemos começar a trabalhar na implementação do `AuthenticationBloc`, que gerenciará a verificação e a atualização do `AuthenticationState` de um usuário em resposta a `AuthenticationEvents`.

Começaremos criando nossa classe `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Nota**: Apenas lendo a definição da classe, já sabemos que este bloc estará convertendo `AuthenticationEvents` em `AuthenticationStates`.

?> **Nota**: Nosso `AuthenticationBloc` depende do `UserRepository`.

Podemos começar substituindo `initialState` pelo estado `AuthenticationInitial()`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Agora tudo o que resta é implementar o `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

Ótimo! Nosso `AuthenticationBloc` final deve se parecer com

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc.dart.md ':include')

Agora que temos nosso `AuthenticationBloc` totalmente implementado, vamos trabalhar na camada de apresentação.

## Splash Page

A primeira coisa que precisamos é de um widget `SplashPage`, que servirá como nossa tela inicial, enquanto o nosso `AuthenticationBloc` determina se um usuário está ou não conectado.

[splash_page.dart](../_snippets/flutter_login_tutorial/splash_page.dart.md ':include')

## Home Page

Em seguida, precisaremos criar nossa `HomePage` para que possamos navegar pelos usuários lá depois que eles fizerem login com êxito.

[home_page.dart](../_snippets/flutter_login_tutorial/home_page.dart.md ':include')

?> **Nota**: Esta é a primeira classe em que estamos usando o `flutter_bloc`. Entraremos em breve em `BlocProvider.of<AuthenticationBloc>(context)`, mas por enquanto sabemos que ele permite que nossa `HomePage` acesse o nosso `AuthenticationBloc`.

?> **Nota**: Estamos adicionando um evento `AuthenticationLoggedOut` ao nosso `AuthenticationBloc` quando um usuário pressiona o botão logout.

Em seguida, precisamos criar um `LoginPage` e `LoginForm`.

Como o `LoginForm` precisará lidar com a entrada do usuário (botão de login pressionado) e precisará ter alguma lógica de negócio (obtendo um token para um determinado nome de usuário/senha), precisaremos criar um `LoginBloc`.

Assim como fizemos no `AuthenticationBloc`, precisaremos definir o `LoginState` e `LoginEvents`. Vamos começar com "LoginState".

## Login States

[login_state.dart](../_snippets/flutter_login_tutorial/login_state.dart.md ':include')

`LoginInitial` é o estado inicial do LoginForm.

`LoginInProgress` é o estado do LoginForm quando estamos validando credenciais

`LoginFailure` é o estado do LoginForm quando uma tentativa de login falha.

Agora que temos o `LoginState` definido, vamos dar uma olhada na classe `LoginEvent`.

## Login Events

[login_event.dart](../_snippets/flutter_login_tutorial/login_event.dart.md ':include')

O `LoginButtonPressed` será adicionado quando um usuário pressionar o botão de login. Ele notificará o `LoginBloc` de que precisa solicitar um token para as credenciais fornecidas.

Agora podemos implementar nosso `LoginBloc`.

## Login Bloc

[login_bloc.dart](../_snippets/flutter_login_tutorial/login_bloc.dart.md ':include')

?> **Nota**: O `LoginBloc` depende do `UserRepository` para autenticar um usuário com um nome de usuário e senha.

?> **Nota**: O `LoginBloc` depende do `AuthenticationBloc` para atualizar o AuthenticationState quando um usuário inserir credenciais válidas.

Agora que temos o nosso `LoginBloc`, podemos começar a trabalhar no `LoginPage` e `LoginForm`.

## Login Page

O widget `LoginPage` servirá como nosso widget Container e fornecerá as dependências necessárias para o widget `LoginForm` (`LoginBloc` e `AuthenticationBloc`).

[login_page.dart](../_snippets/flutter_login_tutorial/login_page.dart.md ':include')

?> **Nota**: `LoginPage` é um `StatelessWidget`. O widget `LoginPage` usa o widget `BlocProvider` para criar, fechar e fornecer o `LoginBloc` para a subárvore.

?> **Nota**: Estamos usando o `UserRepository` injetado para criar nosso `LoginBloc`.

?> **Nota**: Estamos usando o `BlocProvider.of<AuthenticationBloc>(context)` novamente para acessar o `AuthenticationBloc` no `LoginPage`.

Em seguida, vamos em frente e crie nosso `LoginForm`.

## Login Form

[login_form.dart](../_snippets/flutter_login_tutorial/login_form.dart.md ':include')

?> **Nota**: Nosso `LoginForm` usa o widget `BlocBuilder` para que possa ser reconstruído sempre que houver um novo `LoginState`. O BlocBuilder é um widget do Flutter que requer uma função do Bloc e do construtor. O BlocBuilder trata da construção do widget em resposta a novos estados. O `BlocBuilder` é muito semelhante ao` StreamBuilder`, mas possui uma API mais simples para reduzir a quantidade de código padrão necessário e várias otimizações de desempenho.

Não há muito mais acontecendo no widget `LoginForm`, então vamos continuar criando o nosso indicador de carregamento.

## Loading Indicator

[loading_indicator.dart](../_snippets/flutter_login_tutorial/loading_indicator.dart.md ':include')

Agora chegou a hora de juntar tudo e criar o widget principal do aplicativo em `main.dart`.

## Juntando tudo

[main.dart](../_snippets/flutter_login_tutorial/main.dart.md ':include')

?> **Nota**: Novamente, estamos usando o `BlocBuilder` para reagir às alterações no `AuthenticationState`, para que possamos mostrar ao usuário o `SplashPage`, `LoginPage`, `HomePage` ou `LoadingIndicator` com base no atual AuthenticationState.

?> **Nota**: Nosso aplicativo está envolto em um `BlocProvider`, que torna nossa instância do `AuthenticationBloc` disponível para toda a subárvore do widget. O `BlocProvider` é um widget Flutter que fornece um bloc para seus filhos via` BlocProvider.of (context) `. Ele é usado como um widget de injeção de dependência (DI) para que uma única instância de um bloc possa ser fornecida a vários widgets em uma subárvore.

Agora o `BlocProvider.o<AuthenticationBloc>(context)` em nosso widget `HomePage` e `LoginPage` deve fazer sentido.

Como empacotamos nosso `App` dentro de um `BlocProvider<AuthenticationBloc>`, podemos acessar a instância do nosso `AuthenticationBloc` usando o método estático `BlocProvider.of<AuthenticationBloc>(BuildContext contexto)` de qualquer lugar na subárvore.

Neste ponto, temos uma implementação de login bastante sólida e dissociamos nossa camada de apresentação da camada de lógica de negócios usando o Bloc.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
