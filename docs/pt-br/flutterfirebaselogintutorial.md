# Tutorial Login Flutter com Firebase

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um fluxo de login do Firebase no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Setup

Começaremos criando um novo projeto Flutter

[flutter_create.sh](../_snippets/flutter_firebase_login_tutorial/flutter_create.sh.md ':include')

Podemos então substituir o conteúdo de `pubspec.yaml` por

[pubspec.yaml](../_snippets/flutter_firebase_login_tutorial/pubspec.yaml.md ':include')

Observe que estamos especificando um diretório de assets para todos os assets locais de nossos aplicativos. Crie um diretório `assets` na raiz do seu projeto e adicione o recurso [flutter logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png) (que nós usaremos mais tarde).

depois instale todas as dependências

[flutter_packages_get.sh](../_snippets/flutter_firebase_login_tutorial/flutter_packages_get.sh.md ':include')

A última coisa que precisamos fazer é seguir as [instruções de uso do firebase_auth](https://pub.dev/packages/firebase_auth#usage) para conectar nosso aplicativo ao firebase e ativar o [google_signin](https://pub.dev/packages/google_sign_in).

## User Repository

Assim como no [tutorial de login do flutter](./flutterlogintutorial.md), precisaremos criar nosso `UserRepository`, que será responsável por abstrair a implementação subjacente de como autenticamos e recuperamos as informações do usuário.

Vamos criar `user_repository.dart` e começar.

Podemos começar definindo nossa classe `UserRepository` e implementando o construtor. Você pode ver imediatamente que o `UserRepository` dependerá do FirebaseAuth e do GoogleSignIn.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository_constructor.dart.md ':include')

?> **Nota:** Se o `FirebaseAuth` e/ou o GoogleSignIn não forem injetados no `UserRepository`, nós os instanciamos internamente. Isso nos permite injetar instâncias simuladas para que possamos testar facilmente o `UserRepository`.

O primeiro método que vamos implementar chamaremos `signInWithGoogle` e autenticará o usuário usando o pacote `GoogleSignIn`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_google.dart.md ':include')

Em seguida, implementaremos um método `signInWithCredentials` que permitirá que os usuários façam login com suas próprias credenciais usando o `FirebaseAuth`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_credentials.dart.md ':include')

A seguir, precisamos implementar um método `signUp` que permita aos usuários criar uma conta se optarem por não usar o Login do Google.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_up.dart.md ':include')

Precisamos implementar um método `signOut` para que possamos oferecer aos usuários a opção de efetuar logout e limpar suas informações de perfil do dispositivo.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_out.dart.md ':include')

Por fim, precisaremos de dois métodos adicionais: `isSignedIn` e `getUser` para nos permitir verificar se um usuário já está autenticado e recuperar suas informações.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/is_signed_in_and_get_user.dart.md ':include')

?> **Nota:** `getUser` está retornando apenas o endereço de email do usuário atual por uma questão de simplicidade, mas podemos definir nosso próprio modelo de usuário e preenchê-lo com muito mais informações sobre o usuário em aplicativos mais complexos.

Nosso `user_repository.dart` finalizado deve ficar assim:

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository.dart.md ':include')

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

[authentication_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_dir.sh.md ':include')

?> **Dica:** Você pode usar o [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) para gerar os arquivos para você.

[authentication_state.dart](../_snippets/flutter_firebase_login_tutorial/authentication_state.dart.md ':include')

?> **Nota**: O pacote [`equatable`](https://pub.dev/packages/equatable) é usado para poder comparar duas instâncias de `AuthenticationState`. Por padrão, `==` retorna true somente se os dois objetos forem da mesma instância.

?> **Nota**: O `toString` é substituído para facilitar a leitura de um `AuthenticationState` ao imprimi-lo no console ou no `Transitions`.

!> Como estamos usando o `Equatable` para nos permitir comparar diferentes instâncias do `AuthenticationState`, precisamos passar quaisquer propriedades para a superclasse. Sem o `List <Object> get props => [displayName]`, não poderemos comparar adequadamente diferentes instâncias do `AuthenticationSuccess`.

## Authentication Events

Agora que temos nosso `AuthenticationState` definido, precisamos definir os `AuthenticationEvents` aos quais nosso `AuthenticationBloc` reagirá.

Nós vamos precisar:

- um evento `AuthenticationStarted` para notificar o bloc de que ele precisa verificar se o usuário está atualmente autenticado ou não.
- um evento `AuthenticationLoggedIn` para notificar o bloc de que o usuário efetuou login com êxito.
- um evento `AuthenticationLoggedOut` para notificar o bloc de que o usuário efetuou logout com sucesso.

[authentication_event.dart](../_snippets/flutter_firebase_login_tutorial/authentication_event.dart.md ':include')

## Authentication Bloc

Agora que temos nossos `AuthenticationState` e `AuthenticationEvents` definidos, podemos começar a trabalhar na implementação do `AuthenticationBloc`, que gerenciará a verificação e a atualização do `AuthenticationState` de um usuário em resposta a `AuthenticationEvents`.

Começaremos criando nossa classe `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Nota**: Apenas lendo a definição da classe, já sabemos que este bloc estará convertendo `AuthenticationEvents` em `AuthenticationStates`.

?> **Nota**: Nosso `AuthenticationBloc` depende do `UserRepository`.

Podemos começar substituindo `initialState` pelo estado `AuthenticationInitial()`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Agora tudo o que resta é implementar o `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

Criamos funções auxiliares separadas para converter cada `AuthenticationEvent` no `AuthenticationState` adequado, a fim de manter o `mapEventToState` limpo e fácil de ler.

?> **Nota:** Estamos usando `yield *` (yield-each) em `mapEventToState` para separar os manipuladores de eventos em suas próprias funções. `yield *` insere todos os elementos da subsequência na sequência atualmente sendo construída, como se tivéssemos um rendimento individual para cada elemento.

Nosso `authentication_bloc.dart` completo deve agora ficar assim:

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc.dart.md ':include')

Agora que temos nosso `AuthenticationBloc` totalmente implementado, vamos trabalhar na camada de apresentação.

## App

Começaremos removendo tudo do `main.dart` e implementando nossa função principal.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main1.dart.md ':include')

Estamos agrupando todo o nosso widget `App` em um `BlocProvider` para disponibilizar o `AuthenticationBloc` para toda a árvore do widget.

?> `WidgetsFlutterBinding.ensureInitialized()` é necessário no Flutter v1.9.4 + antes de usar qualquer plug-in se o código for executado antes do runApp.

?> `BlocProvider` também controla o fechamento do `AuthenticationBloc` automaticamente, para que não precisemos fazer isso.

Em seguida, precisamos implementar nosso widget `App`.

> `App` será um `StatelessWidget` e será responsável por reagir ao estado `AuthenticationBloc` e renderizar o widget apropriado.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main2.dart.md ':include')

Estamos usando o `BlocBuilder` para renderizar a interface do usuário com base no estado do `AuthenticationBloc`.

Até o momento, não temos widgets para renderizar, mas voltaremos a isso assim que criarmos o `SplashScreen`, `LoginScreen` e `HomeScreen`

## Bloc Delegate

Antes de chegarmos muito longe, é sempre útil implementar nosso próprio `BlocDelegate`, que nos permite substituir `onTransition` e `onError` e nos ajudará a ver todas as mudanças de estado do bloc (transições) e erros em um só lugar!

Crie `simple_bloc_delegate.dart` e vamos implementar rapidamente nosso próprio delegado.

[simple_bloc_delegate.dart](../_snippets/flutter_firebase_login_tutorial/simple_bloc_delegate.dart.md ':include')

Agora podemos conectar nosso `BlocDelegate` no nosso `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main3.dart.md ':include')

## Splash Screen

Em seguida, precisamos criar um widget `SplashScreen` que será renderizado enquanto o nosso `AuthenticationBloc` determina se um usuário está ou não conectado.

Vamos criar `splash_screen.dart` e implementá-lo!

[splash_screen.dart](../_snippets/flutter_firebase_login_tutorial/splash_screen.dart.md ':include')

Como você pode ver, esse widget é super mínimo e você provavelmente deseja adicionar algum tipo de imagem ou animação para torná-lo mais agradável. Por uma questão de simplicidade, vamos deixar como está.

Agora, vamos ligá-lo ao nosso `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main4.dart.md ':include')

Agora, sempre que nosso `AuthenticationBloc` tiver um `estado` de `Não inicializado`, renderizaremos nosso widget `SplashScreen`!

## Home Screen

Em seguida, precisaremos criar nossa `HomeScreen` para que possamos navegar pelos usuários depois que eles tiverem efetuado login com sucesso. Nesse caso, nossa `HomeScreen` permitirá que o usuário efetue logout e também exibirá seu nome atual (email).

Vamos criar `home_screen.dart` e começar.

[home_screen.dart](../_snippets/flutter_firebase_login_tutorial/home_screen.dart.md ':include')

O `HomeScreen` é um `StatelessWidget` que requer que um `nome` seja injetado para que possa renderizar a mensagem de boas-vindas. Ele também usa o `BlocProvider` para acessar o`AuthenticationBloc` via `BuildContext`, de modo que quando um usuário pressiona o botão de logout, podemos adicionar o evento `AuthenticationLoggedOut`.

Agora vamos atualizar nosso `App` para renderizar a `HomeScreen` se o `AuthenticationState` for `AuthenticationSuccess`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main5.dart.md ':include')

## Login States

Finalmente chegou a hora de começar a trabalhar no fluxo de login. Começaremos identificando os diferentes `LoginStates` que teremos.

Crie um diretório `login` e crie o diretório e os arquivos padrão do bloc.

[login_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/login_bloc_dir.sh.md ':include')

Nosso `login/bloc/login_state.dart` deve se parecer com:

[login_state.dart](../_snippets/flutter_firebase_login_tutorial/login_state.dart.md ':include')

Os estados que estamos representando são:

`vazio` é o estado inicial do LoginForm.

`loading` é o estado do LoginForm quando estamos validando credenciais

`fail` é o estado do LoginForm quando uma tentativa de login falha.

`success` é o estado do LoginForm quando uma tentativa de login é bem-sucedida.

Também definimos uma função `copyWith` e `update` por conveniência (que usaremos em breve).

Agora que temos o `LoginState` definido, vamos dar uma olhada na classe `LoginEvent`.

## Login Events

Abra `login/bloc/login_event.dart` e vamos definir e implementar nossos eventos.

[login_event.dart](../_snippets/flutter_firebase_login_tutorial/login_event.dart.md ':include')

Os eventos que definimos são:

`LoginEmailChanged` - notifica o bloc que o usuário alterou o email

`LoginPasswordChanged` - notifica o bloc que o usuário alterou a senha

`Enviado` - notifica o bloc que o usuário enviou o formulário

`LoginWithGooglePressed` - notifica o bloc em que o usuário pressionou o botão Login do Google

`LoginWithCredentialsPressed` - notifica o bloc que o usuário pressionou o botão de logon regular.

## Login Barrel File

Antes de implementar o `LoginBloc`, vamos garantir que nosso arquivo barrel esteja pronto para que possamos importar facilmente todos os arquivos relacionados ao Login Bloc com uma única importação.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_barrel.dart.md ':include')

## Login Bloc

É hora de implementar o nosso `LoginBloc`. Como sempre, precisamos estender o `Bloc` e definir o nosso `initialState` e o `mapEventToState`.

[login_bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_bloc.dart.md ':include')

**Nota:** Nós estamos substituindo o `transformEvents` para rejeitar os eventos `LoginEmailChanged` e `LoginPasswordChanged`, para que possamos dar ao usuário algum tempo para parar de digitar antes de validar a entrada.

Estamos usando uma classe `Validators` para validar o email e a senha que vamos implementar a seguir.

## Validators

Vamos criar `validators.dart` e implementar nossas verificações de validação de e-mail e senha.

[validators.dart](../_snippets/flutter_firebase_login_tutorial/validators.dart.md ':include')

Não há nada de especial acontecendo aqui. É apenas um código Dart antigo simples que usa expressões regulares para validar o email e a senha. Neste ponto, devemos ter um `LoginBloc` totalmente funcional, que possamos conectar à interface do usuário.

## Login Screen

Agora que terminamos o `LoginBloc`, é hora de criar o widget `LoginScreen`, que será responsável por criar e fechar o `LoginBloc`, além de fornecer o andaime para o nosso widget `LoginForm`.

Crie `login/login_screen.dart` e vamos implementá-lo.

[login_screen.dart](../_snippets/flutter_firebase_login_tutorial/login_screen.dart.md ':include')

Novamente, estamos estendendo o `StatelessWidget` e usando um `BlocProvider` para inicializar e fechar o `LoginBloc`, bem como tornar a instância do `LoginBloc` disponível para todos os widgets dentro da subárvore.

Nesse ponto, precisamos implementar o widget `LoginForm`, que será responsável por exibir os botões de formulário e envio para que um usuário se autentique.

## Login Form

Crie `login/login_form.dart` e vamos criar nosso formulário.

[login_form.dart](../_snippets/flutter_firebase_login_tutorial/login_form.dart.md ':include')

Nosso widget `LoginForm` é um `StatefulWidget` porque precisa manter seu próprio `TextEditingControllers` para a entrada de e-mail e senha.

Utilizamos um widget `BlocListener` para executar ações únicas em resposta a alterações de estado. Neste caso, estamos mostrando diferentes widgets `SnackBar` em resposta a um estado pendente / falha. Além disso, se o envio for bem-sucedido, usamos o método `listener` para notificar o `AuthenticationBloc` de que o usuário efetuou login com êxito.

?> **Dica:** Confira a [Receita do SnackBar](recipesfluttershowsnackbar.md) para mais detalhes.

Usamos um widget `BlocBuilder` para reconstruir a interface do usuário em resposta a diferentes `LoginStates`.

Sempre que o email ou a senha são alterados, adicionamos um evento ao `LoginBloc` para validar o estado atual do formulário e retornar o novo estado do formulário.

?> **Nota:** Estamos usando o `Image.asset` para carregar o logotipo flutter do nosso diretório de assets.

Neste ponto, você notará que não implementamos `LoginButton`,`GoogleLoginButton` ou `CreateAccountButton`, portanto faremos isso a seguir.

## Botão de Login

Crie `login/login_button.dart` e vamos implementar rapidamente nosso widget `LoginButton`.

[login_button.dart](../_snippets/flutter_firebase_login_tutorial/login_button.dart.md ':include')

Não há nada de especial acontecendo aqui; apenas um `StatelessWidget` que possui algum estilo e um retorno de chamada `onPressed`, para que possamos ter um `VoidCallback` personalizado sempre que o botão for pressionado.

## Botão Login com Google

Crie `login/google_login_button.dart` e vamos trabalhar no nosso login no Google.

[google_login_button.dart](../_snippets/flutter_firebase_login_tutorial/google_login_button.dart.md ':include')

Novamente, não há muita coisa acontecendo aqui. Temos outro `StatelessWidget`; no entanto, desta vez não estamos expondo um retorno de chamada `onPressed`. Em vez disso, lidamos com o onPressed internamente e adicionamos o evento `LoginWithGooglePressed` ao nosso `LoginBloc`, que tratará do processo de login do Google.

?> **Nota:** Estamos usando [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) para o ícone legal do Google.

## Botão Criar Conta

O último dos três botões é o `CreateAccountButton`. Vamos criar `login/create_account_button.dart` e começar a trabalhar.

[create_account_button.dart](../_snippets/flutter_firebase_login_tutorial/create_account_button.dart.md ':include')

Nesse caso, novamente temos um `StatelessWidget` e novamente lidamos com o retorno de chamada `onPressed` internamente. Desta vez, no entanto, estamos empurrando uma nova rota em resposta ao pressionar o botão para `RegisterScreen`. Vamos construir isso a seguir!

## Register States

Assim como no login, precisamos definir nossos `RegisterStates` antes de prosseguir.

Crie um diretório `register` e crie o diretório e os arquivos padrão do bloc.

[register_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/register_bloc_dir.sh.md ':include')

Nosso `register/bloc/register_state.dart` deve se parecer com:

[register_state.dart](../_snippets/flutter_firebase_login_tutorial/register_state.dart.md ':include')

?> **Nota:** O `RegisterState` é muito semelhante ao `LoginState` e poderíamos ter criado um único estado e o compartilhado entre os dois; no entanto, é muito provável que os recursos de login e registro sejam divergentes e, na maioria dos casos, é melhor mantê-los dissociados.

Em seguida, passaremos para a classe `RegisterEvent`.

## Register Events

Abra `register/bloc/register_event.dart` e vamos implementar nossos eventos.

[register_event.dart](../_snippets/flutter_firebase_login_tutorial/register_event.dart.md ':include')

?> **Nota:** Novamente, a implementação do `RegisterEvent` se parece muito com a implementação do `LoginEvent`, mas como os dois são recursos separados, nós os mantemos independentes neste exemplo.

## Arquivo Barrel Register

Novamente, assim como no login, precisamos criar um arquivo barrel para exportar nossos arquivos relacionados ao bloc de registros.

Abra `bloc.dart` em nosso diretório `register/bloc` e exporte os três arquivos.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_barrel.dart.md ':include')

## Register Bloc

Agora, vamos abrir `register/bloc/register_bloc.dart` e implementar o `RegisterBloc`.

[register_bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_bloc.dart.md ':include')

Assim como antes, precisamos estender o `Bloc`, implementar `initialState` e `mapEventToState`. Opcionalmente, estamos substituindo o `transformEvents` novamente, para que possamos dar aos usuários algum tempo para terminar de digitar antes de validar o formulário.

Agora que o `RegisterBloc` está totalmente funcional, precisamos construir a camada de apresentação.

## Register Screen

Semelhante ao `LoginScreen`, nosso `RegisterScreen` será um `StatelessWidget` responsável por inicializar e fechar o `RegisterBloc`. Ele também fornecerá o andaime para o `RegisterForm`.

Crie `register/register_screen.dart` e vamos implementá-lo.

[register_screen.dart](../_snippets/flutter_firebase_login_tutorial/register_screen.dart.md ':include')

## Register Form

Em seguida, vamos criar o `RegisterForm` que fornecerá os campos de formulário para um usuário criar sua conta.

Crie `register/register_form.dart` e vamos construí-lo.

[register_form.dart](../_snippets/flutter_firebase_login_tutorial/register_form.dart.md ':include')

Novamente, precisamos gerenciar `TextEditingControllers` para a entrada de texto, para que nosso `RegisterForm` precise ser um `StatefulWidget`. Além disso, estamos usando o BlocListener novamente para executar ações únicas em resposta a alterações de estado, como mostrar o SnackBar quando o registro está pendente ou falha. Também estamos adicionando o evento `AuthenticationLoggedIn` ao `AuthenticationBloc` se o registro foi bem-sucedido, para que possamos logar imediatamente o usuário.

?> **Nota:** Estamos usando o `BlocBuilder` para fazer com que nossa interface do usuário responda às alterações no estado `RegisterBloc`.

Vamos construir o nosso widget `RegisterButton` a seguir.

## Botão Registrar

Crie `register/register_button.dart` e vamos começar.

[register_button.dart](../_snippets/flutter_firebase_login_tutorial/register_button.dart.md ':include')

Muito parecido com o modo como configuramos o `LoginButton`, o `RegisterButton` possui um estilo personalizado e expõe um `VoidCallback` para que possamos lidar sempre que um usuário pressionar o botão no widget pai.

Tudo o que resta a fazer é atualizar o widget `App` no `main.dart` para mostrar a `LoginScreen` se o `AuthenticationState` for `AuthenticationFailure`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main6.dart.md ':include')

Nesse ponto, temos uma implementação de login bastante sólida usando o Firebase e dissociamos nossa camada de apresentação da camada de lógica de negócios usando a Biblioteca de Bloc.

O código fonte completo deste exemplo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
