# Tutorial Flutter Firestore Todos

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo Todos reativo que se conecta ao Firestore. Vamos construir no topo do exemplo [flutter todos](https://bloclibrary.dev/#/fluttertodostutorial) para não entrarmos na interface do usuário, pois tudo será o mesmo.

![demo](../assets/gifs/flutter_firestore_todos.gif)

As únicas coisas que vamos refatorar em nosso exemplo de [todos](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos) são a camada de repositório e as partes da camada de bloc.

Começaremos na camada de repositório com o `TodosRepository`.

## Todos Repository

Crie um novo pacote no nível raiz do nosso aplicativo chamado `todos_repository`.

?> **Nota:** O motivo para tornar o repositório um pacote independente é ilustrar que o repositório deve ser dissociado do aplicativo e pode ser reutilizado em vários aplicativos.

Dentro do nosso `todos_repository`, crie a seguinte estrutura de pastas/arquivos.

[todos_repository_dir.sh](../_snippets/flutter_firestore_todos_tutorial/todos_repository_dir.sh.md ':include')

### Dependências

O `pubspec.yaml` deve se parecer com:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/todos_repository_pubspec.yaml.md ':include')

?> **Nota:** Podemos ver imediatamente que nosso `todos_repository` depende de `firebase_core` e `cloud_firestore`.

### Pacote Raiz

O `todos_repository.dart` diretamente dentro do `lib` deve se parecer com:

[todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/todos_repository_library.dart.md ':include')

?> É aqui que todas as nossas classes públicas são exportadas. Se queremos que uma classe seja privada do pacote, devemos nos omitir.

### Entidades

> Entities represent the data provided by our data provider.

O arquivo `entity.dart` é um arquivo barrel que exporta o arquivo` todo_entity.dart`.

[entities.dart](../_snippets/flutter_firestore_todos_tutorial/entities_barrel.dart.md ':include')

Nosso `TodoEntity` é a representação do nosso `Todo` dentro do Firestore.

Crie `todo_entity.dart` e vamos implementá-lo.

[todo_entity.dart](../_snippets/flutter_firestore_todos_tutorial/todo_entity.dart.md ':include')

O `toJson` e o `fromJson` são métodos padrão para converter de/para json.
O `fromSnapshot` e o `toDocument` são específicos do Firestore.

?> **Nota:** O Firestore criará automaticamente o ID do documento quando o inserirmos. Como tal, não queremos duplicar dados armazenando o id em um campo de id.

### Modelos

> Os modelos conterão classes dart simples com as quais trabalharemos em nosso aplicativo Flutter. A separação entre modelos e entidades nos permite alternar nosso provedor de dados a qualquer momento e apenas precisamos alterar a conversão `toEntity` e `fromEntity` em nossa camada de modelo.

Nosso `models.dart` é outro arquivo barrel.
Dentro do `todo.dart` vamos colocar o seguinte código.

[todo.dart](../_snippets/flutter_firestore_todos_tutorial/todo.dart.md ':include')

### Repositório Todos

> `TodosRepository` é a nossa classe base abstrata que podemos estender sempre que quisermos integrar com um` TodosProvider` diferente.

Vamos criar `todos_repository.dart`

[todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/todos_repository.dart.md ':include')

?> **Nota:** Como temos essa interface, é fácil adicionar outro tipo de armazenamento de dados. Se, por exemplo, quisermos usar algo como [sembast](https://pub.dev/flutter/packages?q=sembast), tudo o que precisamos fazer é criar um repositório separado para lidar com o código específico da sembast.

#### Repositório Firebase Todos

> `FirebaseTodosRepository` gerencia a integração com o Firestore e implementa nossa interface `TodosRepository`.

Vamos abrir o `firebase_todos_repository.dart` e implementá-lo!

[firebase_todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/firebase_todos_repository.dart.md ':include')

É isso para o nosso `TodosRepository`, depois precisamos criar um simples `UserRepository` para gerenciar a autenticação de nossos usuários.

## Repositório User

Crie um novo pacote na raiz do nosso aplicativo chamado `user_repository`.

Dentro do nosso `user_repository`, crie a seguinte estrutura de pastas/arquivos.

[user_repository_dir.sh](../_snippets/flutter_firestore_todos_tutorial/user_repository_dir.sh.md ':include')

### Dependencies

O `pubspec.yaml` deve se parecer com:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/user_repository_pubspec.yaml.md ':include')

?> **Nota:** Podemos ver imediatamente que nosso `user_repository` depende de `firebase_auth`.

### Package Raiz

O `user_repository.dart` diretamente dentro de `lib` deve se parecer com:

[user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/user_repository_library.dart.md ':include')

### Repositório User

> `UserRepository` é nossa classe base abstrata que podemos estender sempre que quisermos integrar com um provedor diferente`.

Vamos criar `user_repository.dart`

[user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/user_repository.dart.md ':include')

#### Firebase User Repository

> `FirebaseUserRepository` gerencia a integração com o Firebase e implementa nossa interface `UserRepository`.

Vamos abrir o `firebase_user_repository.dart` e implementá-lo!

[firebase_user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/firebase_user_repository.dart.md ':include')

É isso para o nosso `UserRepository`, depois precisamos configurar nosso aplicativo Flutter para usar nossos novos repositórios.

## Flutter App

### Setup

Vamos criar um novo aplicativo Flutter chamado `flutter_firestore_todos`. Podemos substituir o conteúdo do `pubspec.yaml` pelo seguinte:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/pubspec.yaml.md ':include')

?> **Nota:** Estamos adicionando nosso `todos_repository` e `user_repository` como dependências externas.

### Authentication Bloc

Como queremos poder entrar em nossos usuários, precisamos criar um `AuthenticationBloc`.

?> Se você ainda não viu o [tutorial de login do flutter firebase](https://bloclibrary.dev/#/flutterfirebaselogintutorial), eu recomendo dar uma olhada agora, porque simplesmente vamos reutilizar o mesmo `AuthenticationBloc`.

#### Authentication Events

[authentication_event.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_event.dart.md ':include')

#### Authentication States

[authentication_state.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_state.dart.md ':include')

#### Authentication Bloc

[authentication_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_bloc.dart.md ':include')

Agora que nosso `AuthenticationBloc` foi concluído, precisamos modificar o `TodosBloc` do [Todos Tutorial](https://bloclibrary.dev/#/fluttertodostutorial) para consumir o novo `TodosRepository`.

### Todos Bloc

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/todos_bloc.dart.md ':include')

A principal diferença entre o nosso novo `TodosBloc` e o original está no fato de que no novo tudo é baseado em `Stream` e não em `Future`.

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/map_load_todos_to_state.dart.md ':include')

?> Quando carregamos nosso Todos, estamos assinando o `TodosRepository` e toda vez que um novo Todo entra, adicionamos um evento `TodosUpdated`. Em seguida, lidamos com todos os `TodosUpdates` via:

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/map_todos_updated_to_state.dart.md ':include')

## Juntando tudo

A última coisa que precisamos modificar é o nosso `main.dart`.

[main.dart](../_snippets/flutter_firestore_todos_tutorial/main.dart.md ':include')

As principais diferenças a serem observadas são o fato de envolvermos todo o nosso aplicativo em um `MultiBlocProvider` que inicializa e fornece o `AuthenticationBloc` e o `TodosBloc`. Em seguida, renderizamos o aplicativo Todos apenas se o `AuthenticationState` for `Authenticated` usando o `BlocBuilder`. Todo o resto permanece o mesmo que no `todos tutorial` anterior.

Isso é tudo! Agora implementamos com sucesso um aplicativo firestore todos no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito a camada de apresentação da lógica de negócios e também criamos um aplicativo que é atualizado em tempo real.

O código fonte completo deste exemplo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_firestore_todos).
