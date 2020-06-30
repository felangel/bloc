# Tutorial Pesquisa no Github com Flutter + AngularDart 

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo de pesquisa do Github no Flutter e no AngularDart para demonstrar como podemos compartilhar as camadas de dados e lógica de negócios entre os dois projetos.

![demo](../assets/gifs/flutter_github_search.gif)

![demo](../assets/gifs/angular_github_search.gif)

## Biblioteca Common Github Search

> A biblioteca Common Github Search conterá modelos, o provedor de dados, o repositório e o bloc que será compartilhado entre o AngularDart e o Flutter.

### Setup

Começaremos criando um novo diretório para o nosso aplicativo.

[setup.sh](../_snippets/flutter_angular_github_search/common/setup1.sh.md ':include')

Em seguida, criaremos o Scaffold para a biblioteca `common_github_search`.

[setup.sh](../_snippets/flutter_angular_github_search/common/setup2.sh.md ':include')

Precisamos criar um `pubspec.yaml` com as dependências necessárias.

[pubspec.yaml](../_snippets/flutter_angular_github_search/common/pubspec.yaml.md ':include')

Por fim, precisamos instalar nossas dependências.

[pub_get.sh](../_snippets/flutter_angular_github_search/common/pub_get.sh.md ':include')

É isso para a configuração do projeto! Agora podemos começar a trabalhar na construção do pacote `common_github_search`.

### Client Github

> O `GithubClient` que fornecerá dados brutos da [API do Github](https://developer.github.com/v3/).

?> **Nota:** Você pode ver uma amostra da aparência dos dados que recuperamos [aqui](https://api.github.com/search/repositories?q=dartlang).

Vamos criar `github_client.dart`.

[github_client.dart](../_snippets/flutter_angular_github_search/common/github_client.dart.md ':include')

?> **Nota:** Nosso `GithubClient` está simplesmente fazendo uma solicitação de rede à API de pesquisa de repositório do Github e convertendo o resultado em um `SearchResult` ou `SearchResultError` como um `future`.

Em seguida, precisamos definir nossos modelos `SearchResult` e `SearchResultError`.

#### Modelo Search Result

Crie `search_result.dart`.

[search_result.dart](../_snippets/flutter_angular_github_search/common/search_result.dart.md ':include')

?> **Nota:** A implementação do `SearchResult` depende do `SearchResultItem.fromJson` que ainda não implementamos.

?> **Nota:** Não estamos incluindo propriedades que não serão usadas em nosso modelo.

#### Modelo Search Result Item

Em seguida, criaremos `search_result_item.dart`.

[search_result_item.dart](../_snippets/flutter_angular_github_search/common/search_result_item.dart.md ':include')

?> **Nota:** Novamente, a implementação do `SearchResultItem` depende do `GithubUser.fromJson` que ainda não implementamos.

#### Modelo Github User

Em seguida, criaremos `github_user.dart`.

[github_user.dart](../_snippets/flutter_angular_github_search/common/github_user.dart.md ':include')

Neste ponto, concluímos a implementação do `SearchResult` e suas dependências; portanto, a seguir, passaremos para o `SearchResultError`.

#### Modelo Search Result Error

Crie `search_result_error.dart`.

[search_result_error.dart](../_snippets/flutter_angular_github_search/common/search_result_error.dart.md ':include')

Nosso `GithubClient` está finalizado, e a seguir, passaremos para o `GithubCache`, que será responsável por [memoizar](https://en.wikipedia.org/wiki/Memoization) como uma otimização de desempenho.

### Github Cache

> Nosso `GithubCache` será responsável por lembrar todas as consultas anteriores, para que possamos evitar solicitações de rede desnecessárias à API do Github. Isso também ajudará a melhorar o desempenho do nosso aplicativo.

Crie `github_cache.dart`.

[github_cache.dart](../_snippets/flutter_angular_github_search/common/github_cache.dart.md ':include')

Agora estamos prontos para criar nosso `GithubRepository`!

### Repositório Github

> O Repositório do Github é responsável por criar uma abstração entre a camada de dados (`GithubClient`) e a Camada de Lógica de Negócis (`Bloc`). É também aqui que vamos usar o nosso `GithubCache`.

Crie `github_repository.dart`.

[github_repository.dart](../_snippets/flutter_angular_github_search/common/github_repository.dart.md ':include')

?> **Nota:** O `GithubRepository` depende do `GithubCache` e do `GithubClient` e abstrai a implementação subjacente. Nosso aplicativo nunca precisa saber como os dados estão sendo recuperados ou de onde vêm, pois não devem se importar. Podemos mudar o funcionamento do repositório a qualquer momento e, desde que não alteremos a interface, não precisaremos alterar nenhum código do cliente.

Neste ponto, concluímos a camada do provedor de dados e a camada do repositório, para estarmos prontos para avançar para a camada da lógica de negócios.

### Github Search Event

> Nosso bloc será notificado quando um usuário digitar o nome de um repositório que iremos representar como um `GithubSearchEvent`` TextChanged`.

Crie `github_search_event.dart`.

[github_search_event.dart](../_snippets/flutter_angular_github_search/common/github_search_event.dart.md ':include')

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

[github_search_state.dart](../_snippets/flutter_angular_github_search/common/github_search_state.dart.md ':include')

?> **Nota:** Nós estendemos [`Equatable`](https://pub.dev/packages/equatable) para que possamos comparar instâncias do `GithubSearchState`; por padrão, o operador de igualdade retorna true se e somente se este e outro forem a mesma instância.

Agora que implementamos nossos eventos e estados, podemos criar nosso `GithubSearchBloc`.

### Github Search Bloc

Crie `github_search_bloc.dart`

[github_search_bloc.dart](../_snippets/flutter_angular_github_search/common/github_search_bloc.dart.md ':include')

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

[flutter_create.sh](../_snippets/flutter_angular_github_search/flutter/flutter_create.sh.md ':include')

Em seguida, precisamos atualizar nosso `pubspec.yaml` para incluir todas as dependências necessárias.

[pubspec.yaml](../_snippets/flutter_angular_github_search/flutter/pubspec.yaml.md ':include')

?> **Nota:** Estamos incluindo nossa recém-criada biblioteca `common_github_search` como uma dependência.

Agora precisamos instalar as dependências.

[flutter_packages_get.sh](../_snippets/flutter_angular_github_search/flutter/flutter_packages_get.sh.md ':include')

É isso para a configuração do projeto e, como o pacote `common_github_search` contém nossa camada de dados e nossa lógica de negócios, tudo o que precisamos construir é a camada de apresentação.

### Search Form

Vamos precisar criar um formulário com o widget `SearchBar` e `SearchBody`.

- O `SearchBar` será responsável por receber as informações do usuário.
- O `SearchBody` será responsável por exibir os resultados da pesquisa, carregar indicadores e erros.

Vamos criar `search_form.dart`.

> Nosso `SearchForm` será um `StatelessWidget` que renderiza os widgets `SearchBar` e `SearchBody`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_form.dart.md ':include')

Em seguida, implementaremos o `_SearchBar`.

### Search Bar

> `SearchBar` também será um `StatefulWidget` porque precisará manter seu próprio `TextController` para que possamos acompanhar o que um usuário inseriu como entrada.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_bar.dart.md ':include')

?> **Nota:** O `_SearchBar` acessa o `GitHubSearchBloc` via `BlocProvider.of<GithubSearchBloc>(context)` e notifica o bloc de eventos `TextChanged`.

Terminamos com `_SearchBar`, agora em `_SearchBody`.

### Search Body

> `SearchBody` é um `StatelessWidget` que será responsável por exibir resultados de pesquisa, erros e indicadores de carregamento. Será o consumidor do `GithubSearchBloc`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_body.dart.md ':include')

?> **Nota:** O `_SearchBody` também acessa o `GithubSearchBloc` via `BlocProvider` e usa o `BlocBuilder` para reconstruir em resposta a alterações de estado.

Se o nosso estado for `SearchStateSuccess`, renderizamos `_SearchResults` que iremos implementar a seguir.

### Search Results

> `SearchResults` é um `StatelessWidget` que pega um `List<SearchResultItem>` e os exibe como uma lista de `SearchResultItems`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_results.dart.md ':include')

?> **Nota:** Usamos `ListView.builder` para construir uma lista rolável de `SearchResultItem`.

Está na hora de implementar o _SearchResultItem.

### Search Result Item

> `SearchResultItem` é um `StatelessWidget` e é responsável por renderizar as informações para um único resultado de pesquisa. Também é responsável por manipular a interação do usuário e navegar para o URL do repositório em um toque do usuário.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_result_item.dart.md ':include')

?> **Nota:** Utilizamos o pacote [url_launcher](https://pub.dev/packages/url_launcher) para abrir urls externas.

### Juntando tudo

Nesse ponto, nosso `search_form.dart` deve se parecer com

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_form_complete.dart.md ':include')

Agora tudo o que precisamos fazer é implementar nosso aplicativo principal em `main.dart`.

[main.dart](../_snippets/flutter_angular_github_search/flutter/main.dart.md ':include')

?> **Nota:** Nosso `GithubRepository` é criado em `main` e injetado em nosso `App`. Nosso `SearchForm` é envolvido em um `BlocProvider`, responsável por inicializar, fechar e disponibilizar a instância do `GithubSearchBloc` para o widget `SearchForm` e seus filhos.

Isso é tudo! Agora implementamos com sucesso um aplicativo de pesquisa do github no Flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com sucesso nossa camada de apresentação da nossa lógica de negócios.

O código fonte completo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/github_search/flutter_github_search).

Por fim, vamos criar nosso aplicativo AngularDart Github Search.

## AngularDart Github Search

> O AngularDart Github Search será um aplicativo AngularDart que reutiliza os modelos, provedores de dados, repositórios e blocs do `common_github_search` para implementar o Github Search.

### Setup

Precisamos começar criando um novo projeto AngularDart em nosso diretório github_search no mesmo nível que `common_github_search`.

[stagehand.sh](../_snippets/flutter_angular_github_search/angular/stagehand.sh.md ':include')

!> Ative o stagehand executando `pub global ativar o stagehand`

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por:

[pubspec.yaml](../_snippets/flutter_angular_github_search/angular/pubspec.yaml.md ':include')

### Search Form

Assim como em nosso aplicativo Flutter, precisamos criar um `SearchForm` com os componentes `SearchBar` e `SearchBody`.

> Nosso componente `SearchForm` implementará `OnInit` e `OnDestroy` porque precisará criar e fechar um `GithubSearchBloc`.

- O `SearchBar` será responsável por receber as informações do usuário.
- O `SearchBody` será responsável por exibir os resultados da pesquisa, carregar indicadores e erros.

Vamos criar `search_form_component.dart`

[search_form_component.dart](../_snippets/flutter_angular_github_search/angular/search_form_component.dart.md ':include')

?> **Nota:** O `GithubRepository` é injetado no `SearchFormComponent`.

?> **Nota:** O `GithubSearchBloc` é criado e fechado pelo `SearchFormComponent`.

Nosso modelo (`search_form_component.html`) terá a aparência de:

[search_form_component.html](../_snippets/flutter_angular_github_search/angular/search_form_component.html.md ':include')

Em seguida, implementaremos o componente `SearchBar`.

### Search Bar

> `SearchBar` é um componente que será responsável por receber as entradas do usuário e notificar o `GithubSearchBloc` das alterações de texto.

Crie `search_bar_component.dart`.

[search_bar_component.dart](../_snippets/flutter_angular_github_search/angular/search_bar_component.dart.md ':include')

?> **Nota:** O `SearchBarComponent` depende do `GitHubSearchBloc` porque é responsável por notificar o bloc de eventos `TextChanged`.

Em seguida, podemos criar `search_bar_component.html`.

[search_bar_component.html](../_snippets/flutter_angular_github_search/angular/search_bar_component.html.md ':include')

Terminamos com o `SearchBar`, agora no `SearchBody`.

### Search Body

> `SearchBody` é um componente que será responsável por exibir resultados de pesquisa, erros e indicadores de carregamento. Será o consumidor do `GithubSearchBloc`.

Crie `search_body_component.dart`

[search_body_component.dart](../_snippets/flutter_angular_github_search/angular/search_body_component.dart.md ':include')

?> **Nota:** `SearchBodyComponent` depende do `GithubSearchState`, que é fornecido pelo `GithubSearchBloc` usando o canal do bloc `angular_bloc`.

Crie `search_body_component.html`

[search_body_component.html](../_snippets/flutter_angular_github_search/angular/search_body_component.html.md ':include')

Se o nosso estado `isSuccess`, renderizamos `SearchResults`, que iremos implementar a seguir.

### Search Results

> `SearchResults` é um componente que pega um `List<SearchResultItem>` e os exibe como uma lista de `SearchResultItems`.

Crie `search_results_component.dart`

[search_results_component.dart](../_snippets/flutter_angular_github_search/angular/search_results_component.dart.md ':include')

Em seguida, criaremos `search_results_component.html`.

[search_results_component.html](../_snippets/flutter_angular_github_search/angular/search_results_component.html.md ':include')

?> **Nota:** Usamos `ngFor` para construir uma lista de componentes do `SearchResultItem`.

Está na hora de implementar o `SearchResultItem`.

### Search Result Item

> `SearchResultItem` é um componente responsável por renderizar as informações para um único resultado de pesquisa. Também é responsável por manipular a interação do usuário e navegar para o URL do repositório em um toque do usuário.

Crie `search_result_item_component.dart`.

[search_result_item_component.dart](../_snippets/flutter_angular_github_search/angular/search_result_item_component.dart.md ':include')

e o modelo correspondente em `search_result_item_component.html`.

[search_result_item_component.html](../_snippets/flutter_angular_github_search/angular/search_result_item_component.html.md ':include')

### Juntando tudo

Temos todos os nossos componentes e agora é hora de reuni-los no nosso `app_component.dart`.

[app_component.dart](../_snippets/flutter_angular_github_search/angular/app_component.dart.md ':include')

?> **Nota:** Estamos criando o `GithubRepository` no `AppComponent` e injetando-o no componente `SearchForm`.

Isso é tudo! Agora, implementamos com sucesso um aplicativo de pesquisa do github no AngularDart usando os pacotes `bloc` e `angular_bloc` e separamos com êxito a camada de apresentação da lógica de negócios.

O código fonte completo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search).

## Sumário

Neste tutorial, criamos um aplicativo Flutter e AngularDart enquanto compartilhamos todos os modelos, provedores de dados e blocs entre os dois.

A única coisa que realmente tivemos que escrever duas vezes foi a camada de apresentação (UI), que é impressionante em termos de eficiência e velocidade de desenvolvimento. Além disso, é bastante comum que aplicativos da Web e aplicativos móveis tenham experiências e estilos de usuário diferentes e essa abordagem realmente demonstra como é fácil criar dois aplicativos que parecem totalmente diferentes, mas compartilham as mesmas camadas de dados e lógica de negócios.

O código fonte completo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/github_search).
