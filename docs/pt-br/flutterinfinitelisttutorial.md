# Flutter Infinite List Tutorial

![iniciante](https://img.shields.io/badge/level-intermediate-orange.svg)

> Neste tutorial, implementaremos um aplicativo que busca dados na rede e os carrega à medida que o usuário rola usando o Flutter e a biblioteca bloc.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Setup

Vamos começar criando um novo projeto Flutter

```bash
flutter create flutter_infinite_list
```

Podemos então avançar e substituir o conteúdo de pubspec.yaml por

```yaml
name: flutter_infinite_list
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  http: ^0.12.0
  equatable: ^1.0.0

flutter:
  uses-material-design: true
```

e instale todas as nossas dependências

```bash
flutter packages get
```

## REST API

Para este aplicativo de demonstração, usaremos [jsonplaceholder](http://jsonplaceholder.typicode.com) como nossa fonte de dados.

?> jsonplaceholder é uma API REST online que serve dados falsos; é muito útil para criar protótipos.

Abra uma nova guia no seu navegador e visite https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 para ver o que a API retorna.

```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
  }
]
```

?> **Nota:** em nossa URL, especificamos o início e o limite como parâmetros de consulta para a solicitação GET.

Ótimo, agora que sabemos como serão os nossos dados, vamos criar o modelo.

## Modelo

Crie `post.dart` e vamos começar a criar o modelo do nosso objeto Post.

```dart
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  List<Object> get props => [id, title, body];

  @override
  String toString() => 'Post { id: $id }';
}
```

O `Post` é apenas uma classe com um `id`, `title` e `body`.

?> Substituímos a função `toString` para ter uma representação de string personalizada do nosso` Post` para mais tarde.

?> Estendemos [`Equatable`] (https://pub.dev/packages/equatable) para que possamos comparar `Posts`; por padrão, o operador de igualdade retorna true se e somente se este e outro forem a mesma instância.

Agora que temos o nosso modelo de objeto "Post", vamos começar a trabalhar no Business Logic Component (bloc).

## Eventos Post

Antes de mergulharmos na implementação, precisamos definir o que nosso `PostBloc` fará.

Em um nível alto, ele responderá à entrada do usuário (rolagem) e buscará mais postagens para que a camada de apresentação as exiba. Vamos começar criando nosso "Evento".

Nosso `PostBloc` estará respondendo apenas a um único evento; `Buscar` que será adicionado pela camada de apresentação sempre que precisar de mais mensagens para apresentar. Como nosso evento `Fetch` é um tipo de `PostEvent`, podemos criar `bloc/post_event.dart` e implementar o evento dessa forma.

```dart
import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Fetch extends PostEvent {}
```

?> Novamente, estamos substituindo `toString` por uma representação de string de nosso evento mais fácil de ler. Novamente, estamos estendendo [`Equatable`] (https://pub.dev/packages/equatable) para que possamos comparar instâncias para igualdade.

Para recapitular, nosso `PostBloc` receberá `PostEvents` e os converterá em `PostStates`. Definimos todos os nossos `PostEvents` (Fetch); portanto, a seguir, vamos definir nosso `PostState`.

## Estados Post

Nossa camada de apresentação precisará ter várias informações para se apresentar adequadamente:

- `PostUninitialized`- informa a camada de apresentação que precisa para renderizar um indicador de carregamento enquanto o lote inicial de postagens é carregado

- `PostLoaded`- informará a camada de apresentação que possui conteúdo para renderizar
  - `posts`- será o `List <Post>` que será exibido
  - `hasReachedMax`- diz à camada de apresentação se atingiu ou não o número máximo de postagens
- `PostError`- irá dizer à camada de apresentação que ocorreu um erro ao buscar postagens

Agora podemos criar `bloc/post_state.dart` e implementá-lo dessa maneira.

```dart
import 'package:equatable/equatable.dart';

import 'package:flutter_infinite_list/models/models.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostUninitialized extends PostState {}

class PostError extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  const PostLoaded({
    this.posts,
    this.hasReachedMax,
  });

  PostLoaded copyWith({
    List<Post> posts,
    bool hasReachedMax,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [posts, hasReachedMax];

  @override
  String toString() =>
      'PostLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
```

?> Implementamos o `copyWith` para que possamos copiar uma instância do `PostLoaded` e atualizar zero ou mais propriedades convenientemente (isso será útil mais tarde).

Agora que temos nossos `Events` e `States` implementados, podemos criar nosso `PostBloc`.

Para facilitar a importação de nossos estados e eventos com uma única importação, podemos criar `bloc/bloc.dart` que exporta todos eles (adicionaremos nossa exportação `post_bloc.dart` na próxima seção).

```dart
export './post_event.dart';
export './post_state.dart';
```

## Bloc Post

Para simplificar, nosso `PostBloc` terá uma dependência direta de um `cliente http`; no entanto, em um aplicativo de produção, você pode injetar um cliente api e usar o padrão de repositório [docs] (./ architecture.md).

Vamos criar `post_bloc.dart` e criar nossoc`PostBloc` vazio.

```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/post.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  // TODO: implement initialState
  PostState get initialState => null;

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    // TODO: implement mapEventToState
    yield null;
  }
}
```

?> **Nota:** apenas a partir da declaração da classe, podemos dizer que nosso PostBloc aceitará os PostEvents como entrada e saída de PostStates.

Podemos começar implementando `initialState`, que será o estado do nosso `PostBloc` antes que quaisquer eventos sejam adicionados.

```dart
@override
get initialState => PostUninitialized();
```

Em seguida, precisamos implementar o `mapEventToState`, que será acionado toda vez que um `PostEvent` for adicionado.

```dart
@override
Stream<PostState> mapEventToState(PostEvent event) async* {
  final currentState = state;
  if (event is Fetch && !_hasReachedMax(currentState)) {
    try {
      if (currentState is PostUninitialized) {
        final posts = await _fetchPosts(0, 20);
        yield PostLoaded(posts: posts, hasReachedMax: false);
        return;
      }
      if (currentState is PostLoaded) {
        final posts =
            await _fetchPosts(currentState.posts.length, 20);
        yield posts.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PostLoaded(
                posts: currentState.posts + posts,
                hasReachedMax: false,
              );
      }
    } catch (_) {
      yield PostError();
    }
  }
}

bool _hasReachedMax(PostState state) =>
    state is PostLoaded && state.hasReachedMax;

Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
  final response = await httpClient.get(
      'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((rawPost) {
      return Post(
        id: rawPost['id'],
        title: rawPost['title'],
        body: rawPost['body'],
      );
    }).toList();
  } else {
    throw Exception('error fetching posts');
  }
}
```

Nosso `PostBloc` renderá sempre que houver um novo estado, pois retorna um `Stream <PostState>`. Confira os [principais conceitos](https://bloclibrary.dev/#/coreconcepts?id=streams) para obter mais informações sobre `Streams` e outros conceitos principais.

Agora, toda vez que um `PostEvent` é adicionado, se for um evento` Fetch` e houver mais postagens a serem buscadas, nosso `PostBloc` buscará as próximas 20 postagens.

A API retornará uma matriz vazia se tentarmos buscar além do número máximo de postagens (100), portanto, se retornarmos uma matriz vazia, nosso bloc `produzirá` o currentState, exceto que definiremos `hasReachedMax` como true.

Se não podemos recuperar os posts, lançamos uma exceção e `yield` `PostError ()`.

Se pudermos recuperar as postagens, retornamos `PostLoaded ()`, que pega toda a lista de postagens.

Uma otimização que podemos fazer é `rejeitar` os `Eventos` para evitar spam desnecessariamente em nossa API. Podemos fazer isso substituindo o método `transform` no nosso` PostBloc`.

?> **Nota:** Sobrescrevendo o `transform` nos permite transformar a Stream<Event> antes que o mapEventToState seja chamado. Isso permite que operações como distinct(), debounceTime(), etc ... sejam aplicadas.

```dart
@override
Stream<PostState> transformEvents(
  Stream<PostEvent> events,
  Stream<PostState> Function(PostEvent event) next,
) {
  return super.transformEvents(
    events.debounceTime(
      Duration(milliseconds: 500),
    ),
    next,
  );
}
```

Nosso `PostBloc` finalizado deve ficar assim:

```dart
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:flutter_infinite_list/post.dart';
import 'package:flutter_infinite_list/bloc/bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  Stream<PostState> transformEvents(
    Stream<PostEvent> events,
    Stream<PostState> Function(PostEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  get initialState => PostUninitialized();

  @override
  Stream<PostState> mapEventToState(event) async* {
    final currentState = state;
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostUninitialized) {
          final posts = await _fetchPosts(0, 20);
          yield PostLoaded(posts: posts, hasReachedMax: false);
        }
        if (currentState is PostLoaded) {
          final posts = await _fetchPosts(currentState.posts.length, 20);
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostLoaded(
                  posts: currentState.posts + posts, hasReachedMax: false);
        }
      } catch (_) {
        yield PostError();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostLoaded && state.hasReachedMax;

  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }
}
```

Não se esqueça de atualizar o `bloc/bloc.dart` para incluir o nosso` PostBloc`!

```dart
export './post_bloc.dart';
export './post_event.dart';
export './post_state.dart';
```

Ótimo! Agora que terminamos de implementar a lógica de negócios, tudo o que resta fazer é implementar a camada de apresentação.

## Camada de Apresentação

Em nosso `main.dart`, podemos começar implementando nossa função principal e chamando `runApp` para renderizar nosso widget raiz.

No nosso widget `App`, usamos o `BlocProvider` para criar e fornecer uma instância do `PostBloc` para a subárvore. Além disso, adicionamos um evento `Fetch` para que, quando o aplicativo for carregado, ele solicite o lote inicial de Posts.

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_infinite_list/bloc/bloc.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: BlocProvider(
          create: (context) =>
              PostBloc(httpClient: http.Client())..add(Fetch()),
          child: HomePage(),
        ),
      ),
    );
  }
}
```

Em seguida, precisamos implementar nosso widget `HomePage`, que apresentará nossas postagens e se conectará ao nosso `PostBloc`.

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is PostError) {
          return Center(
            child: Text('failed to fetch posts'),
          );
        }
        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Text('no posts'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.posts.length
                  ? BottomLoader()
                  : PostWidget(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
                ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(Fetch());
    }
  }
}
```

?> `HomePage` é um `StatefulWidget` porque precisará manter um `ScrollController`. Em `initState`, adicionamos um ouvinte ao nosso `ScrollController` para que possamos responder aos eventos de rolagem. Também acessamos nossa instância `PostBloc` através de `BlocProvider.of <PostBloc> (context)`.

Seguindo em frente, nosso método de compilação retorna um `BlocBuilder`. O `BlocBuilder` é um widget Flutter do [pacote flutter_bloc](https://pub.dev/packages/flutter_bloc) que lida com a construção de um widget em resposta a novos estados do bloc. Sempre que nosso estado `PostBloc` mudar, nossa função de construtor será chamada com o novo `PostState`.

!> Precisamos lembrar de descartar nosso `ScrollController` quando o StatefulWidget for descartado.

Sempre que o usuário rola, calculamos a que distância estão da parte inferior da página e se a distância é ≤ nosso `_scrollThreshold`, adicionamos um evento `Fetch` para carregar mais postagens.

Em seguida, precisamos implementar nosso widget `BottomLoader`, que indicará ao usuário que estamos carregando mais postagens.

```dart
class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
```

Por fim, precisamos implementar nosso `PostWidget` que renderizará um Post individual.

```dart
class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: TextStyle(fontSize: 10.0),
      ),
      title: Text(post.title),
      isThreeLine: true,
      subtitle: Text(post.body),
      dense: true,
    );
  }
}
```

Neste ponto, devemos poder executar nosso aplicativo e tudo deve funcionar; no entanto, há mais uma coisa que podemos fazer.

Um bônus adicional de usar a biblioteca de blocs é que podemos ter acesso a todas as `Transições` em um só lugar.

> A mudança de um estado para outro é chamada de `Transição`.

?> Uma `Transição` consiste no estado atual, no evento e no próximo estado.

Mesmo que neste aplicativo tenha apenas um bloc, é bastante comum em aplicativos maiores ter muitos blocs gerenciando diferentes partes do estado do aplicativo.

Se quisermos fazer algo em resposta a todas as `Transições`, podemos simplesmente criar nosso próprio `BlocDelegate`.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> Tudo o que precisamos fazer é estender o `BlocDelegate` e substituir o método `onTransition`.

Para dizer ao Bloc para usar nosso `SimpleBlocDelegate`, precisamos apenas ajustar nossa função principal.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}
```

Agora, quando executamos nosso aplicativo, toda vez que ocorre uma transição do bloc, podemos ver a transição impressa no console.

?> Na prática, você pode criar diferentes `BlocDelegates` e, como todas as alterações de estado são registradas, somos capazes de instrumentar nossos aplicativos com muita facilidade e rastrear todas as interações do usuário e alterações de estado em um só lugar!

Isso é tudo! Agora implementamos com sucesso uma lista infinita no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito nossa camada de apresentação de nossa lógica de negócios.

Nossa `HomePage` não faz ideia de onde as `Posts` são provenientes ou como estão sendo recuperadas. Por outro lado, nosso `PostBloc` não faz ideia de como o `State` está sendo renderizado, ele simplesmente converte eventos em estados.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
