# Tutorial Pesquisa no Github com Flutter + AngularDart 

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo de pesquisa do Github no Flutter e no AngularDart para demonstrar como podemos compartilhar as camadas de dados e lógica de negócios entre os dois projetos.

![demo](../assets/gifs/flutter_github_search.gif)

![demo](../assets/gifs/angular_github_search.gif)

## Biblioteca Common Github Search

> A biblioteca Common Github Search conterá modelos, o provedor de dados, o repositório e o bloc que será compartilhado entre o AngularDart e o Flutter.

### Setup

Começaremos criando um novo diretório para o nosso aplicativo.

```bash
mkdir github_search && cd github_search
```

Em seguida, criaremos o Scaffold para a biblioteca `common_github_search`.

```bash
mkdir common_github_search
```

Precisamos criar um `pubspec.yaml` com as dependências necessárias.

```yaml
name: common_github_search
description: Shared Code between AngularDart and Flutter
version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  meta: ^1.1.6
  bloc: ^4.0.0
  equatable: ^1.0.0
  http: ^0.12.0
```

Por fim, precisamos instalar nossas dependências.

```bash
pub get
```

É isso para a configuração do projeto! Agora podemos começar a trabalhar na construção do pacote `common_github_search`.

### Client Github

> O `GithubClient` que fornecerá dados brutos da [API do Github](https://developer.github.com/v3/).

?> **Nota:** Você pode ver uma amostra da aparência dos dados que recuperamos [aqui](https://api.github.com/search/repositories?q=dartlang).

Vamos criar `github_client.dart`.

```dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:common_github_search/common_github_search.dart';

class GithubClient {
  final String baseUrl;
  final http.Client httpClient;

  GithubClient({
    http.Client httpClient,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  }) : this.httpClient = httpClient ?? http.Client();

  Future<SearchResult> search(String term) async {
    final response = await httpClient.get(Uri.parse("$baseUrl$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}
```

?> **Nota:** Nosso `GithubClient` está simplesmente fazendo uma solicitação de rede à API de pesquisa de repositório do Github e convertendo o resultado em um `SearchResult` ou `SearchResultError` como um `future`.

Em seguida, precisamos definir nossos modelos `SearchResult` e `SearchResultError`.

#### Modelo Search Result

Crie `search_result.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class SearchResult {
  final List<SearchResultItem> items;

  const SearchResult({this.items});

  static SearchResult fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) =>
            SearchResultItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return SearchResult(items: items);
  }
}
```

?> **Nota:** A implementação do `SearchResult` depende do `SearchResultItem.fromJson` que ainda não implementamos.

?> **Nota:** Não estamos incluindo propriedades que não serão usadas em nosso modelo.

#### Modelo Search Result Item

Em seguida, criaremos `search_result_item.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class SearchResultItem {
  final String fullName;
  final String htmlUrl;
  final GithubUser owner;

  const SearchResultItem({this.fullName, this.htmlUrl, this.owner});

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }
}
```

?> **Nota:** Novamente, a implementação do `SearchResultItem` depende do `GithubUser.fromJson` que ainda não implementamos.

#### Modelo Github User

Em seguida, criaremos `github_user.dart`.

```dart
class GithubUser {
  final String login;
  final String avatarUrl;

  const GithubUser({this.login, this.avatarUrl});

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}
```

Neste ponto, concluímos a implementação do `SearchResult` e suas dependências; portanto, a seguir, passaremos para o `SearchResultError`.

#### Modelo Search Result Error

Crie `search_result_error.dart`.

```dart
class SearchResultError {
  final String message;

  const SearchResultError({this.message});

  static SearchResultError fromJson(dynamic json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }
}
```

Nosso `GithubClient` está finalizado, e a seguir, passaremos para o `GithubCache`, que será responsável por [memoizar](https://en.wikipedia.org/wiki/Memoization) como uma otimização de desempenho.

### Github Cache

> Nosso `GithubCache` será responsável por lembrar todas as consultas anteriores, para que possamos evitar solicitações de rede desnecessárias à API do Github. Isso também ajudará a melhorar o desempenho do nosso aplicativo.

Crie `github_cache.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class GithubCache {
  final _cache = <String, SearchResult>{};

  SearchResult get(String term) => _cache[term];

  void set(String term, SearchResult result) => _cache[term] = result;

  bool contains(String term) => _cache.containsKey(term);

  void remove(String term) => _cache.remove(term);
}
```

Agora estamos prontos para criar nosso `GithubRepository`!

### Repositório Github

> O Repositório do Github é responsável por criar uma abstração entre a camada de dados (`GithubClient`) e a Camada de Lógica de Negócis (`Bloc`). É também aqui que vamos usar o nosso `GithubCache`.

Crie `github_repository.dart`.

```dart
import 'dart:async';

import 'package:common_github_search/common_github_search.dart';

class GithubRepository {
  final GithubCache cache;
  final GithubClient client;

  GithubRepository(this.cache, this.client);

  Future<SearchResult> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term);
    } else {
      final result = await client.search(term);
      cache.set(term, result);
      return result;
    }
  }
}
```

?> **Nota:** O `GithubRepository` depende do `GithubCache` e do `GithubClient` e abstrai a implementação subjacente. Nosso aplicativo nunca precisa saber como os dados estão sendo recuperados ou de onde vêm, pois não devem se importar. Podemos mudar o funcionamento do repositório a qualquer momento e, desde que não alteremos a interface, não precisaremos alterar nenhum código do cliente.

Neste ponto, concluímos a camada do provedor de dados e a camada do repositório, para estarmos prontos para avançar para a camada da lógica de negócios.

### Github Search Event

> Nosso bloc será notificado quando um usuário digitar o nome de um repositório que iremos representar como um `GithubSearchEvent`` TextChanged`.

Crie `github_search_event.dart`.

```dart
import 'package:equatable/equatable.dart';

abstract class GithubSearchEvent extends Equatable {
  const GithubSearchEvent();
}

class TextChanged extends GithubSearchEvent {
  final String text;

  const TextChanged({this.text});

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'TextChanged { text: $text }';
}
```

?> **Nota:** Nós estendemos [`Equatable`](https://pub.dev/packages/equatable) para que possamos comparar instâncias do `GithubSearchEvent`; por padrão, o operador de igualdade retorna true se e somente se este e outro forem a mesma instância.

### Github Search State

Nossa camada de apresentação precisará ter várias informações para se apresentar adequadamente:

- `SearchStateEmpty`- diz à camada de apresentação que nenhuma entrada foi dada pelo usuário

- `SearchStateLoading`- informa a camada de apresentação que deve exibir algum tipo de indicador de carregamento
- `SearchStateSuccess`- diz à camada de apresentação que possui dados para apresentar
  - `items`- será o `List<SearchResultItem>` que será exibido

- `SearchStateError`-- informa à camada de apresentação que ocorreu um erro ao buscar repositórios
  - `error`- será o erro exato que ocorreu

Agora podemos criar `github_search_state.dart` e implementá-lo assim.

```dart
import 'package:equatable/equatable.dart';

import 'package:common_github_search/common_github_search.dart';

abstract class GithubSearchState extends Equatable {
  const GithubSearchState();

  @override
  List<Object> get props => [];
}

class SearchStateEmpty extends GithubSearchState {}

class SearchStateLoading extends GithubSearchState {}

class SearchStateSuccess extends GithubSearchState {
  final List<SearchResultItem> items;

  const SearchStateSuccess(this.items);

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class SearchStateError extends GithubSearchState {
  final String error;

  const SearchStateError(this.error);

  @override
  List<Object> get props => [error];
}
```

?> **Nota:** Nós estendemos [`Equatable`](https://pub.dev/packages/equatable) para que possamos comparar instâncias do `GithubSearchState`; por padrão, o operador de igualdade retorna true se e somente se este e outro forem a mesma instância.

Agora que implementamos nossos eventos e estados, podemos criar nosso `GithubSearchBloc`.

### Github Search Bloc

Crie `github_search_bloc.dart`

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import 'package:common_github_search/common_github_search.dart';

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  final GithubRepository githubRepository;

  GithubSearchBloc({@required this.githubRepository});

  @override
  Stream<GithubSearchState> transformEvents(
    Stream<GithubSearchEvent> events,
    Stream<GithubSearchState> Function(GithubSearchEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  void onTransition(
      Transition<GithubSearchEvent, GithubSearchState> transition) {
    print(transition);
  }

  @override
  GithubSearchState get initialState => SearchStateEmpty();

  @override
  Stream<GithubSearchState> mapEventToState(
    GithubSearchEvent event,
  ) async* {
    if (event is TextChanged) {
      final String searchTerm = event.text;
      if (searchTerm.isEmpty) {
        yield SearchStateEmpty();
      } else {
        yield SearchStateLoading();
        try {
          final results = await githubRepository.search(searchTerm);
          yield SearchStateSuccess(results.items);
        } catch (error) {
          yield error is SearchResultError
              ? SearchStateError(error.message)
              : SearchStateError('something went wrong');
        }
      }
    }
  }
}
```

?> **Nota:** Nosso `GithubSearchBloc` converte o `GithubSearchEvent` em `GithubSearchState` e tem uma dependência do `GithubRepository`.

?> **Nota:** Sobrescrevemos o método `transformEvents` para realizar [debounce](http://reactivex.io/documentation/operators/debounce.html) com o `GithubSearchEvents`.

?> **Nota:** Sobrescrevemos `onTransition` para que possamos registrar sempre que ocorrer uma alteração de estado.

Impressionante! Todos nós terminamos o nosso pacote `common_github_search`.
O produto final deve ter a aparência [assim](https://github.com/felangel/Bloc/tree/master/examples/github_search/common_github_search).

Em seguida, trabalharemos na implementação do Flutter.

## Flutter Github Search

> Flutter Github Search será um aplicativo Flutter que reutiliza os modelos, provedores de dados, repositórios e blocs de `common_github_search` para implementar o Github Search.

### Setup

Precisamos começar criando um novo projeto Flutter em nosso diretório `github_search` no mesmo nível que `common_github_search`.

```bash
flutter create flutter_github_search
```

Em seguida, precisamos atualizar nosso `pubspec.yaml` para incluir todas as dependências necessárias.

```yaml
name: flutter_github_search
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^4.0.0
  url_launcher: ^4.0.3
  common_github_search:
    path: ../common_github_search

flutter:
  uses-material-design: true
```

?> **Nota:** Estamos incluindo nossa recém-criada biblioteca `common_github_search` como uma dependência.

Agora precisamos instalar as dependências.

```bash
flutter packages get
```

É isso para a configuração do projeto e, como o pacote `common_github_search` contém nossa camada de dados e nossa lógica de negócios, tudo o que precisamos construir é a camada de apresentação.

### Search Form

Vamos precisar criar um formulário com o widget `SearchBar` e `SearchBody`.

- O `SearchBar` será responsável por receber as informações do usuário.
- O `SearchBody` será responsável por exibir os resultados da pesquisa, carregar indicadores e erros.

Vamos criar `search_form.dart`.

> Nosso `SearchForm` será um `StatelessWidget` que renderiza os widgets `SearchBar` e `SearchBody`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}
```

Em seguida, implementaremos o `_SearchBar`.

### Search Bar

> `SearchBar` também será um `StatefulWidget` porque precisará manter seu próprio `TextController` para que possamos acompanhar o que um usuário inseriu como entrada.

```dart
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = BlocProvider.of<GithubSearchBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _githubSearchBloc.add(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(TextChanged(text: ''));
  }
}
```

?> **Nota:** O `_SearchBar` acessa o `GitHubSearchBloc` via `BlocProvider.of<GithubSearchBloc>(context)` e notifica o bloc de eventos `TextChanged`.

Terminamos com `_SearchBar`, agora em `_SearchBody`.

### Search Body

> `SearchBody` é um `StatelessWidget` que será responsável por exibir resultados de pesquisa, erros e indicadores de carregamento. Será o consumidor do `GithubSearchBloc`.

```dart
class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}
```

?> **Nota:** O `_SearchBody` também acessa o `GithubSearchBloc` via `BlocProvider` e usa o `BlocBuilder` para reconstruir em resposta a alterações de estado.

Se o nosso estado for `SearchStateSuccess`, renderizamos `_SearchResults` que iremos implementar a seguir.

### Search Results

> `SearchResults` é um `StatelessWidget` que pega um `List<SearchResultItem>` e os exibe como uma lista de `SearchResultItems`.

```dart
class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}
```

?> **Nota:** Usamos `ListView.builder` para construir uma lista rolável de `SearchResultItem`.

Está na hora de implementar o _SearchResultItem.

### Search Result Item

> `SearchResultItem` é um `StatelessWidget` e é responsável por renderizar as informações para um único resultado de pesquisa. Também é responsável por manipular a interação do usuário e navegar para o URL do repositório em um toque do usuário.

```dart
class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
```

?> **Nota:** Utilizamos o pacote [url_launcher](https://pub.dev/packages/url_launcher) para abrir urls externas.

### Juntando tudo

Nesse ponto, nosso `search_form.dart` deve se parecer com

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = BlocProvider.of<GithubSearchBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _githubSearchBloc.add(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
```

Agora tudo o que precisamos fazer é implementar nosso aplicativo principal em `main.dart`.

```dart
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:flutter_github_search/search_form.dart';

void main() {
  final GithubRepository _githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );

  runApp(App(githubRepository: _githubRepository));
}

class App extends StatelessWidget {
  final GithubRepository githubRepository;

  const App({
    Key key,
    @required this.githubRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Search',
      home: Scaffold(
        appBar: AppBar(title: Text('Github Search')),
        body: BlocProvider(
          create: (context) =>
              GithubSearchBloc(githubRepository: githubRepository),
          child: SearchForm(),
        ),
      ),
    );
  }
}
```

?> **Nota:** Nosso `GithubRepository` é criado em `main` e injetado em nosso `App`. Nosso `SearchForm` é envolvido em um `BlocProvider`, responsável por inicializar, fechar e disponibilizar a instância do `GithubSearchBloc` para o widget `SearchForm` e seus filhos.

Isso é tudo! Agora implementamos com sucesso um aplicativo de pesquisa do github no Flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com sucesso nossa camada de apresentação da nossa lógica de negócios.

O código fonte completo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/github_search/flutter_github_search).

Por fim, vamos criar nosso aplicativo AngularDart Github Search.

## AngularDart Github Search

> O AngularDart Github Search será um aplicativo AngularDart que reutiliza os modelos, provedores de dados, repositórios e blocs do `common_github_search` para implementar o Github Search.

### Setup

Precisamos começar criando um novo projeto AngularDart em nosso diretório github_search no mesmo nível que `common_github_search`.

```bash
stagehand web-angular
```

!> Ative o stagehand executando `pub global ativar o stagehand`

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por:

```yaml
name: angular_github_search
description: A web app that uses AngularDart Components

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  angular: ^5.3.0
  angular_components: ^0.13.0
  angular_bloc: ^4.0.0
  common_github_search:
    path: ../common_github_search

dev_dependencies:
  angular_test: ^2.0.0
  build_runner: ">=1.6.2 <2.0.0"
  build_test: ^0.10.2
  build_web_compilers: ">=1.2.0 <3.0.0"
  test: ^1.0.0
```

### Search Form

Assim como em nosso aplicativo Flutter, precisamos criar um `SearchForm` com os componentes `SearchBar` e `SearchBody`.

> Nosso componente `SearchForm` implementará `OnInit` e `OnDestroy` porque precisará criar e fechar um `GithubSearchBloc`.

- O `SearchBar` será responsável por receber as informações do usuário.
- O `SearchBody` será responsável por exibir os resultados da pesquisa, carregar indicadores e erros.

Vamos criar `search_form_component.dart`

```dart
import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
    selector: 'search-form',
    templateUrl: 'search_form_component.html',
    directives: [
      SearchBarComponent,
      SearchBodyComponent,
    ],
    pipes: [
      BlocPipe
    ])
class SearchFormComponent implements OnInit, OnDestroy {
  @Input()
  GithubRepository githubRepository;

  GithubSearchBloc githubSearchBloc;

  @override
  void ngOnInit() {
    githubSearchBloc = GithubSearchBloc(
      githubRepository: githubRepository,
    );
  }

  @override
  void ngOnDestroy() {
    githubSearchBloc.close();
  }
}
```

?> **Nota:** O `GithubRepository` é injetado no `SearchFormComponent`.

?> **Nota:** O `GithubSearchBloc` é criado e fechado pelo `SearchFormComponent`.

Nosso modelo (`search_form_component.html`) terá a aparência de:

```html
<div>
  <h1>Github Search</h1>
  <search-bar [githubSearchBloc]="githubSearchBloc"></search-bar>
  <search-body [state]="githubSearchBloc | bloc"></search-body>
</div>
```

Em seguida, implementaremos o componente `SearchBar`.

### Search Bar

> `SearchBar` é um componente que será responsável por receber as entradas do usuário e notificar o `GithubSearchBloc` das alterações de texto.

Crie `search_bar_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-bar',
  templateUrl: 'search_bar_component.html',
)
class SearchBarComponent {
  @Input()
  GithubSearchBloc githubSearchBloc;

  void onTextChanged(String text) {
    githubSearchBloc.add(TextChanged(text: text));
  }
}
```

?> **Nota:** O `SearchBarComponent` depende do `GitHubSearchBloc` porque é responsável por notificar o bloc de eventos `TextChanged`.

Em seguida, podemos criar `search_bar_component.html`.

```html
<label for="term" class="clip">Enter a search term</label>
<input
  id="term"
  placeholder="Enter a search term"
  class="input-reset outline-transparent glow o-50 bg-near-black near-white w-100 pv2 border-box b--white-50 br-0 bl-0 bt-0 bb-ridge mb3"
  autofocus
  (keyup)="onTextChanged($event.target.value)"
/>
```

Terminamos com o `SearchBar`, agora no `SearchBody`.

### Search Body

> `SearchBody` é um componente que será responsável por exibir resultados de pesquisa, erros e indicadores de carregamento. Será o consumidor do `GithubSearchBloc`.

Crie `search_body_component.dart`

```dart
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'search-body',
  templateUrl: 'search_body_component.html',
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialIconComponent,
    SearchResultsComponent,
  ],
)
class SearchBodyComponent {
  @Input()
  GithubSearchState state;

  bool get isEmpty => state is SearchStateEmpty;
  bool get isLoading => state is SearchStateLoading;
  bool get isSuccess => state is SearchStateSuccess;
  bool get isError => state is SearchStateError;

  List<SearchResultItem> get items =>
      isSuccess ? (state as SearchStateSuccess).items : [];

  String get error => isError ? (state as SearchStateError).error : '';
}
```

?> **Nota:** `SearchBodyComponent` depende do `GithubSearchState`, que é fornecido pelo `GithubSearchBloc` usando o canal do bloc `angular_bloc`.

Crie `search_body_component.html`

```html
<div *ngIf="state != null" class="mw10">
  <div *ngIf="isEmpty" class="tc">
    <material-icon icon="info" class="light-blue"></material-icon>
    <p>Please enter a term to begin</p>
  </div>
  <div *ngIf="isLoading" class="tc"><material-spinner></material-spinner></div>
  <div *ngIf="isError" class="tc">
    <material-icon icon="error" class="light-red"></material-icon>
    <p>{{ error }}</p>
  </div>
  <div *ngIf="isSuccess">
    <div *ngIf="items.length == 0" class="tc">
      <material-icon icon="warning" class="light-yellow"></material-icon>
      <p>No Results</p>
    </div>
    <search-results [items]="items"></search-results>
  </div>
</div>
```

Se o nosso estado `isSuccess`, renderizamos `SearchResults`, que iremos implementar a seguir.

### Search Results

> `SearchResults` é um componente que pega um `List<SearchResultItem>` e os exibe como uma lista de `SearchResultItems`.

Crie `search_results_component.dart`

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'search-results',
  templateUrl: 'search_results_component.html',
  directives: [coreDirectives, SearchResultItemComponent],
)
class SearchResultsComponent {
  @Input()
  List<SearchResultItem> items;
}
```

Em seguida, criaremos `search_results_component.html`.

```html
<ul class="list pa0 ma0">
  <li *ngFor="let item of items" class="pa2 cf">
    <search-result-item [item]="item"></search-result-item>
  </li>
</ul>
```

?> **Nota:** Usamos `ngFor` para construir uma lista de componentes do `SearchResultItem`.

Está na hora de implementar o `SearchResultItem`.

### Search Result Item

> `SearchResultItem` é um componente responsável por renderizar as informações para um único resultado de pesquisa. Também é responsável por manipular a interação do usuário e navegar para o URL do repositório em um toque do usuário.

Crie `search_result_item_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-result-item',
  templateUrl: 'search_result_item_component.html',
)
class SearchResultItemComponent {
  @Input()
  SearchResultItem item;
}
```

e o modelo correspondente em `search_result_item_component.html`.

```html
<div class="fl w-10 h-auto">
  <img class="br-100" src="{{ item?.owner.avatarUrl }}" />
</div>
<div class="fl w-90 ph3">
  <h1 class="f5 ma0">{{ item.fullName }}</h1>
  <p>
    <a href="{{ item?.htmlUrl }}" class="light-blue" target="_blank"
      >{{ item?.htmlUrl }}</a
    >
  </p>
</div>
```

### Juntando tudo

Temos todos os nossos componentes e agora é hora de reuni-los no nosso `app_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'my-app',
  template:
      '<search-form [githubRepository]="githubRepository"></search-form>',
  directives: [SearchFormComponent],
)
class AppComponent {
  final githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );
}
```

?> **Nota:** Estamos criando o `GithubRepository` no `AppComponent` e injetando-o no componente `SearchForm`.

Isso é tudo! Agora, implementamos com sucesso um aplicativo de pesquisa do github no AngularDart usando os pacotes `bloc` e `angular_bloc` e separamos com êxito a camada de apresentação da lógica de negócios.

O código fonte completo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search).

## Sumário

Neste tutorial, criamos um aplicativo Flutter e AngularDart enquanto compartilhamos todos os modelos, provedores de dados e blocs entre os dois.

A única coisa que realmente tivemos que escrever duas vezes foi a camada de apresentação (UI), que é impressionante em termos de eficiência e velocidade de desenvolvimento. Além disso, é bastante comum que aplicativos da Web e aplicativos móveis tenham experiências e estilos de usuário diferentes e essa abordagem realmente demonstra como é fácil criar dois aplicativos que parecem totalmente diferentes, mas compartilham as mesmas camadas de dados e lógica de negócios.

O código fonte completo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/github_search).
