# Flutter Todos Tutorial

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo de Todos com Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_todos.gif)

## Setup

Começaremos criando um novo projeto Flutter

[script](../_snippets/flutter_todos_tutorial/flutter_create.sh.md ':include')

Podemos então substituir o conteúdo de `pubspec.yaml` por

[pubspec.yaml](../_snippets/flutter_todos_tutorial/pubspec.yaml.md ':include')

e instale todas as dependências

[script](../_snippets/flutter_todos_tutorial/flutter_packages_get.sh.md ':include')

?> **Nota:** Substituímos algumas dependências porque as reutilizaremos em [Exemplos de arquitetura de Brian Egan](https://github.com/brianegan/flutter_architecture_samples).

## App Keys

Antes de pularmos para o código do aplicativo, vamos criar `flutter_todos_keys.dart`. Este arquivo conterá chaves que usaremos para identificar exclusivamente widgets importantes. Posteriormente, podemos escrever testes que encontram widgets baseados em chaves.

[flutter_todos_keys.dart](../_snippets/flutter_todos_tutorial/flutter_todos_keys.dart.md ':include')

Iremos fazer referência a essas chaves no restante do tutorial.

?> **Nota:** Você pode verificar os testes de integração para o aplicativo [aqui](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). You can also check out unit and widget tests [here](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Localização

Um último conceito que abordaremos antes de entrar no aplicativo em si é a localização. Crie `localization.dart` e criaremos a base para o suporte em vários idiomas.

[localization.dart](../_snippets/flutter_todos_tutorial/localization.dart.md ':include')

Agora podemos importar e fornecer nosso `FlutterBlocLocalizationsDelegate` ao nosso `MaterialApp` (mais adiante neste tutorial).

Para mais informações sobre localização, consulte a [documentação oficial](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos Repository

Neste tutorial, não entraremos nos detalhes da implementação do `TodosRepository` porque ele foi implementado por [Brian Egan](https://github.com/brianegan) e é compartilhado entre todos os [Exemplos](https://github.com/brianegan/flutter_architecture_samples). Em um nível alto, o `TodosRepository` irá expor um método para `loadTodos` e `saveTodos`. Isso é tudo o que precisamos saber, para o restante do tutorial, focaremos nas camadas Bloc e Presentation.

## Todos Bloc

> Nosso `TodosBloc` será responsável por converter o `TodosEvents` em `TodosStates` e gerenciará a lista de todos.

### Modelo

A primeira coisa que precisamos fazer é definir o nosso modelo Todo. Cada tarefa precisará ter um ID, uma tarefa, uma nota opcional e um sinalizador concluído opcional.

Vamos criar um diretório `models` e criar `todo.dart`.

[todo.dart](../_snippets/flutter_todos_tutorial/todo.dart.md ':include')

?> **Nota:** Estamos utilizando o pacote [Equatable](https://pub.dev/packages/equatable) para que possamos comparar instâncias de `Todos` sem precisar substituir manualmente `== `e` hashCode`.

Em seguida, precisamos criar o `TodosState` que nossa camada de apresentação receberá.

### States

Vamos criar `blocs/todos/todos_state.dart` e definir os diferentes estados que precisaremos lidar.

Os três estados que implementaremos são:

- `TodosLoadInProgress` - o estado enquanto nosso aplicativo está buscando todos no repositório.
- `TodosLoadSuccess` - o estado do nosso aplicativo depois que todos foram carregados com sucesso.
- `TodosLoadFailure` - o estado do nosso aplicativo se todos não foram carregados com sucesso.

[todos_state.dart](../_snippets/flutter_todos_tutorial/todos_state.dart.md ':include')

Em seguida, vamos implementar os eventos que precisaremos manipular.

### Events

Os eventos que precisaremos tratar no nosso `TodosBloc` são:

- `TodosLoaded` - diz ao bloc que ele precisa carregar o todos do `TodosRepository`.
- `TodoAdded` - diz ao bloc que ele precisa adicionar um novo todo à lista de todos.
- `TodoUpdated` - informa ao bloc que ele precisa atualizar um todo existente.
- `TodoDeleted` - informa ao bloc que ele precisa remover um todo existente.
- `ClearCompleted` - informa ao bloc que ele precisa remover todos os todos concluídos.
- `ToggleAll` - informa ao bloc que ele precisa alternar o estado concluído de todos os todos.

Crie `blocs/todos/todos_event.dart` e vamos implementar os eventos que descrevemos acima.

[todos_event.dart](../_snippets/flutter_todos_tutorial/todos_event.dart.md ':include')

Agora que temos nossos `TodosStates` e `TodosEvents` implementados, podemos implementar nosso `TodosBloc`.

### Bloc

Vamos criar `blocs/todos/todos_bloc.dart` e começar! Nós apenas precisamos implementar `initialState` e `mapEventToState`.

[todos_bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc.dart.md ':include')

!> Quando produzimos um estado nos manipuladores privados `mapEventToState`, estamos sempre produzindo um novo estado em vez de alterar o `state`. Isso ocorre porque toda vez que damos um yield, o bloc comparará o `state` com o `nextState` e acionará apenas uma mudança de estado (`transição`) se os dois estados **não forem iguais**. Se apenas mudarmos e produzirmos a mesma instância de estado, o `state == nextState` será avaliado como verdadeiro e nenhuma alteração de estado ocorrerá.

Nosso `TodosBloc` dependerá do `TodosRepository` para que possa carregar e salvar todos. Ele terá um estado inicial de `TodosLoadInProgress` e define os manipuladores privados para cada um dos eventos. Sempre que o `TodosBloc` altera a lista de todos, ele chama o método` saveTodos` no `TodosRepository` para manter tudo persistido localmente.

### Arquivo Barrel

Agora que terminamos o nosso `TodosBloc`, podemos criar um arquivo barrel para exportar todos os nossos arquivos de bloc e facilitar a importação mais tarde.

Crie `blocs/todos/todos.dart` e exporte o bloc, eventos e estados:

[bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc_barrel.dart.md ':include')

## Filtered Todos Bloc

> O `FilteredTodosBloc` será responsável por reagir às alterações de estado no `TodosBloc` que acabamos de criar e manterá o estado de todos filtrados em nosso aplicativo.

### Modelo

Antes de começarmos a definir e implementar o `TodosStates`, precisaremos implementar um modelo `VisibilityFilter` que determine quais todos os nossos `FilteredTodosState` conterão. Nesse caso, teremos três filtros:

- `all` - mostra todos Todos (padrão)
- `active` - mostra apenas Todos que não foram concluídos
- 'concluído' mostra apenas Todos os que foram concluídos

Podemos criar `models/visible_filter.dart` e definir nosso filtro como uma enumeração:

[visibility_filter.dart](../_snippets/flutter_todos_tutorial/visibility_filter.dart.md ':include')

### Estados

Assim como fizemos com o `TodosBloc`, precisaremos definir os diferentes estados para o nosso `FilteredTodosBloc`.

Nesse caso, temos apenas dois estados:

- `FilteredTodosLoadInProgress` - o estado enquanto estamos buscando todos
- `FilteredTodosLoadSuccess` - o estado em que não estamos mais buscando todos

Vamos criar `blocs/filtrado_todos/filtrado_todos_state.dart` e implementar os dois estados.

[filtered_todos_state.dart](../_snippets/flutter_todos_tutorial/filtered_todos_state.dart.md ':include')

?> **Nota:** O estado `FilteredTodosLoadSuccess` contém a lista de todos filtrados, bem como o filtro de visibilidade ativo.

### Eventos

Vamos implementar dois eventos para o nosso `FilteredTodosBloc`:

- `FilterUpdated` - que notifica o bloc que o filtro de visibilidade foi alterado
- `TodosUpdated` - que notifica o bloc de que a lista de todos mudou

Crie `blocs/filtrado_todos/filtrado_todos_event.dart` e vamos implementar os dois eventos.

[filtered_todos_event.dart](../_snippets/flutter_todos_tutorial/filtered_todos_event.dart.md ':include')

Estamos prontos para implementar nosso `FilteredTodosBloc` a seguir!

### Bloc

Nosso `FilteredTodosBloc` será semelhante ao nosso `TodosBloc`; no entanto, em vez de depender do `TodosRepository`, ele dependerá do próprio `TodosBloc`. Isso permitirá que o `FilteredTodosBloc` atualize seu estado em resposta a alterações de estado no `TodosBloc`.

Crie `blocs/filtrado_todos/filtrado_todos_bloc.dart` e vamos começar.

[filtered_todos_bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc.dart.md ':include')

!> Criamos um `StreamSubscription` para o fluxo do `TodosStates` para que possamos ouvir as alterações de estado no `TodosBloc`. Substituímos o método de fechamento do bloc e cancelamos a assinatura para que possamos limpar depois que o bloc for fechado.

### Arquivo Barrel

Assim como antes, podemos criar um arquivo barrel para facilitar a importação das várias classes todos filtradas.

Crie `blocs/filtrado_todos/filtrado_todos.dart` e exporte os três arquivos:

[bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc_barrel.dart.md ':include')

Em seguida, vamos implementar o `StatsBloc`.

## Stats Bloc

> O `StatsBloc` será responsável por manter as estatísticas do número de todos ativos e do número de todos concluídos. Da mesma forma, para o `FilteredTodosBloc`, ele terá uma dependência do `TodosBloc` para que possa reagir a alterações no estado do `TodosBloc`.

### Estado

Nosso `StatsBloc` terá dois estados nos quais ele pode estar:

- `StatsLoadInProgress` - o estado em que as estatísticas ainda não foram calculadas.
- `StatsLoadSuccess` - o estado em que as estatísticas foram calculadas.

Crie `blocs/stats/stats_state.dart` e vamos implementar nosso` StatsState`.

[stats_state.dart](../_snippets/flutter_todos_tutorial/stats_state.dart.md ':include')

Em seguida, vamos definir e implementar os `StatsEvents`.

### Eventos

Haverá apenas um único evento que nosso `StatsBloc` responderá a:` StatsUpdated`. Este evento será adicionado sempre que o estado do `TodosBloc` mudar, para que o nosso `StatsBloc` possa recalcular as novas estatísticas.

Crie `blocs/stats/stats_event.dart` e vamos implementá-lo.

[stats_event.dart](../_snippets/flutter_todos_tutorial/stats_event.dart.md ':include')

Agora estamos prontos para implementar nosso `StatsBloc`, que será muito parecido com o `FilteredTodosBloc`.

### Bloc

Nosso `StatsBloc` terá uma dependência do `TodosBloc`, o que lhe permitirá atualizar seu estado em resposta a alterações de estado no `TodosBloc`.

Crie `blocs/stats/stats_bloc.dart` e vamos começar.

[stats_bloc.dart](../_snippets/flutter_todos_tutorial/stats_bloc.dart.md ':include')

Isso é tudo! Nosso `StatsBloc` recalcula seu estado, que contém o número de todos ativos e o número de todos concluídos em cada alteração de estado do nosso `TodosBloc`.

Agora que terminamos o `StatsBloc`, temos apenas um último bloc para implementar: o `TabBloc`.

## Tab Bloc

> O `TabBloc` será responsável por manter o estado das guias em nossa aplicação. Ele usará o `TabEvents` como entrada e a saída do `AppTabs`.

### Modelo/Estado

Precisamos definir um modelo `AppTab` que também usaremos para representar o `TabState`. O `AppTab` será apenas um `enum` que representa a guia ativa em nosso aplicativo. Como o aplicativo que estamos construindo terá apenas duas guias: todos e estatísticas, precisamos apenas de dois valores.

Crie `models/app_tab.dart`:

[app_tab.dart](../_snippets/flutter_todos_tutorial/app_tab.dart.md ':include')

### Evento

Nosso `TabBloc` será responsável por manipular um único `TabEvent`:

- `TabUpdated` - que notifica o bloc que a guia ativa atualizou

Crie `blocs/tab/tab_event.dart`:

[tab_event.dart](../_snippets/flutter_todos_tutorial/tab_event.dart.md ':include')

### Bloc

Nossa implementação do `TabBloc` será super simples. Como sempre, precisamos apenas implementar `initialState` e `mapEventToState`.

Crie `blocs/tab/tab_bloc.dart` e vamos fazer a implementação rapidamente.

[tab_bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc.dart.md ':include')

Eu te disse que seria simples. Tudo o que o `TabBloc` está fazendo é definir o estado inicial na guia todos e manipular o evento `TabUpdated`, produzindo uma nova instância do `AppTab`.

### Arquivo Barrel

Por fim, criaremos outro arquivo barrel para nossas exportações do `TabBloc`. Crie `blocs/tab/tab.dart` e exporte os dois arquivos:

[bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc_barrel.dart.md ':include')

## Bloc Delegate

Antes de avançarmos para a camada de apresentação, implementaremos nosso próprio `BlocDelegate`, o que nos permitirá lidar com todas as alterações e erros de estado em um único local. É realmente útil para coisas como logs ou análises do desenvolvedor.

Crie `blocs/simple_bloc_delegate.dart` e vamos começar.

[simple_bloc_delegate.dart](../_snippets/flutter_todos_tutorial/simple_bloc_delegate.dart.md ':include')

Tudo o que estamos fazendo neste caso é imprimir todas as alterações de estado (`transições`) e erros no console, para que possamos ver o que está acontecendo quando estamos executando nosso aplicativo. Você pode conectar seu `BlocDelegate` ao google analytics, sentry, crashlytics, etc ...

## Barrel de Blocs

Agora que temos todos os nossos blocs implementados, podemos criar um arquivo barrel.

Crie `blocs/blocs.dart` e exporte todos os nossos blocs para que possamos importar convenientemente qualquer código de bloc com uma única importação.

[blocs.dart](../_snippets/flutter_todos_tutorial/blocs_barrel.dart.md ':include')

A seguir, focaremos na implementação das principais telas em nosso aplicativo Todos.

## Screens

### Home Screen

> Nosso `HomeScreen` será responsável por criar o `Scaffold` do nosso aplicativo. Ele manterá os widgets `AppBar`,`BottomNavigationBar`, bem como os widgets `Stats`/`FilteredTodos` (dependendo da guia ativa).

Vamos criar um novo diretório chamado `screens` onde colocaremos todos os nossos novos widgets de tela e depois criaremos` screens/home_screen.dart`.

[home_screen.dart](../_snippets/flutter_todos_tutorial/home_screen.dart.md ':include')

O `HomeScreen` acessa o `TabBloc` usando o `BlocProvider.of<TabBloc>(context)`, que será disponibilizado no nosso widget raiz `TodosApp` (veremos mais adiante neste tutorial).

Em seguida, implementaremos o `DetailsScreen`.

### Details Screen

> O `DetailsScreen` exibe todos os detalhes do trabalho selecionado e permite que o usuário edite ou exclua o trabalho.

Crie `screens/details_screen.dart` e vamos construí-lo.

[details_screen.dart](../_snippets/flutter_todos_tutorial/details_screen.dart.md ':include')

?> **Nota:** O `DetailsScreen` requer um ID de todo o trabalho para que ele possa obter os detalhes do todo a partir do `TodosBloc` e para que ele possa ser atualizado sempre que os detalhes de um todo forem alterados (o ID de um todo não pode ser alterado).

As principais coisas a serem observadas são que existe um `IconButton` que adiciona um evento `TodoDeleted`, bem como uma caixa de seleção que adiciona um evento `TodoUpdated`.

Há também outro `FloatingActionButton` que navega o usuário para o `AddEditScreen` com o `isEditing` definido como `true`. Vamos dar uma olhada no `AddEditScreen` a seguir.

### Add/Edit Screen

> O widget `AddEditScreen` permite ao usuário criar um novo trabalho ou atualizar um trabalho existente com base no sinalizador `isEditing` que é passado pelo construtor.

Crie `screens/add_edit_screen.dart` e vamos dar uma olhada na implementação.

[add_edit_screen.dart](../_snippets/flutter_todos_tutorial/add_edit_screen.dart.md ':include')

Não há nada específico de bloc neste widget. É simplesmente apresentar um formulário e:

- se `isEditing` for verdadeiro, o formulário é preenchido com os detalhes de tarefas existentes.
- caso contrário, as entradas estarão vazias para que o usuário possa criar um novo todo.

Ele usa uma função de retorno de chamada `onSave` para notificar seu pai do todo atualizado ou recém-criado.

É o caso das telas em nosso aplicativo. Antes de esquecermos, vamos criar um arquivo barrel para exportá-las.

### Barrel de Screens

Crie `screens/screens.dart` e exporte todos os três.

[screens.dart](../_snippets/flutter_todos_tutorial/screens_barrel.dart.md ':include')

Em seguida, vamos implementar todos os "widgets" (qualquer coisa que não seja uma tela).

## Widgets

### Botão de Filtrar

> O widget `FilterButton` será responsável por fornecer ao usuário uma lista de opções de filtro e notificará o `FilteredTodosBloc` quando um novo filtro for selecionado.

Vamos criar um novo diretório chamado `widgets` e colocar nossa implementação `FilterButton` em `widgets/filter_button.dart`.

[filter_button.dart](../_snippets/flutter_todos_tutorial/filter_button.dart.md ':include')

O `FilterButton` precisa responder às alterações de estado no `FilteredTodosBloc`, para que ele use o `BlocProvider` para acessar o `FilteredTodosBloc` no `BuildContext`. Ele então usa o `BlocBuilder` para renderizar novamente sempre que o `FilteredTodosBloc` mudar de estado.

O restante da implementação é puro Flutter e não há muita coisa acontecendo para que possamos avançar para o widget `ExtraActions`.

### Ações Extra

> Da mesma forma que o `FilterButton`, o widget `ExtraActions` é responsável por fornecer ao usuário uma lista de opções extras: Alternar Todos e Limpando Todos.

Como este widget não se importa com os filtros, ele irá interagir com o `TodosBloc` em vez do `FilteredTodosBloc`.

Vamos criar o modelo `ExtraAction` em `models/extra_action.dart`.

[extra_action.dart](../_snippets/flutter_todos_tutorial/extra_action.dart.md ':include')

E não esqueça de exportá-lo no arquivo barrel `models/models.dart`.

A seguir, vamos criar `widgets/extra_actions.dart` e implementá-lo.

[extra_actions.dart](../_snippets/flutter_todos_tutorial/extra_actions.dart.md ':include')

Assim como no `FilterButton`, usamos o `BlocProvider` para acessar o `TodosBloc` no `BuildContext` e no `BlocBuilder` para responder às alterações de estado no `TodosBloc`.

Com base na ação selecionada, o widget adiciona um evento ao `TodosBloc` para os estados de conclusão `ToggleAll` todos ou para todos os `ClearCompleted`.

A seguir, veremos o widget `TabSelector`.

### Tab Selector

> O widget `TabSelector` é responsável por exibir as guias na `BottomNavigationBar` e manipular a entrada do usuário.

Vamos criar `widgets/tab_selector.dart` e implementá-lo.

[tab_selector.dart](../_snippets/flutter_todos_tutorial/tab_selector.dart.md ':include')

Você pode ver que não há dependência de blocs neste widget; apenas chama `onTabSelected` quando uma guia é selecionada e também recebe uma `activeTab` como entrada para que ele saiba qual guia está atualmente selecionada.

A seguir, veremos o widget `FilteredTodos`.

### Filtered Todos

> O widget `FilteredTodos` é responsável por mostrar uma lista de todos com base no filtro ativo atual.

Crie `widgets/filter_todos.dart` e vamos implementá-lo.

[filtered_todos.dart](../_snippets/flutter_todos_tutorial/filtered_todos.dart.md ':include')

Assim como os widgets anteriores que escrevemos, o widget `FilteredTodos` usa o `BlocProvider` para acessar os blocs (neste caso, o `FilteredTodosBloc` e o `TodosBloc` são necessários).

?> O `FilteredTodosBloc` é necessário para nos ajudar a renderizar todos corretos com base no filtro atual

?> O `TodosBloc` é necessário para permitir adicionar/excluir todos em resposta a interações do usuário, como passar um item individual em um todo.

No widget `FilteredTodos`, o usuário pode navegar para a `DetailsScreen`, onde é possível editar ou excluir o todo selecionado. Como nosso widget `FilteredTodos` renderiza uma lista de widgets `TodoItem`, vamos dar uma olhada nos próximos.

### Todo Item

> `TodoItem` é um widget sem estado que é responsável por processar um único todo e manipular as interações do usuário (toques/swipes).

Crie `widgets/todo_item.dart` e vamos construí-lo.

[todo_item.dart](../_snippets/flutter_todos_tutorial/todo_item.dart.md ':include')

Novamente, observe que o `TodoItem` não possui código específico de bloc. Ele é renderizado com base no todo que passamos pelo construtor e chama as funções de retorno de chamada injetadas sempre que o usuário interage com o todo.

Em seguida, criaremos o `DeleteTodoSnackBar`.

### Delete Todo SnackBar

> O `DeleteTodoSnackBar` é responsável por indicar ao usuário que um todo foi excluído e permite que o usuário desfaça sua ação.

Crie `widgets/delete_todo_snack_bar.dart` e vamos implementá-lo.

[delete_todo_snack_bar.dart](../_snippets/flutter_todos_tutorial/delete_todo_snack_bar.dart.md ':include')

Você provavelmente está percebendo um padrão: esse widget também não possui código específico do bloc. Ele simplesmente recebe um todo para renderizar a tarefa e chama uma função de retorno de chamada chamada `onUndo` se um usuário pressionar o botão desfazer.

Estamos quase terminando; faltam apenas mais dois widgets!

### Loading Indicator

> O widget `LoadingIndicator` é um widget sem estado que é responsável por indicar ao usuário que algo está em andamento.

Crie `widgets/loading_indicator.dart` e vamos escrever.

[loading_indicator.dart](../_snippets/flutter_todos_tutorial/loading_indicator.dart.md ':include')

Não há muito o que discutir aqui; estamos apenas usando um `CircularProgressIndicator` envolvido em um widget` Center` (novamente sem código específico de bloc).

Por fim, precisamos criar nosso widget `Stats`.

### Stats

> O widget `Stats` é responsável por mostrar ao usuário quantos todos estão ativos (em andamento) vs concluídos.

Vamos criar `widgets/stats.dart` e dar uma olhada na implementação.

[stats.dart](../_snippets/flutter_todos_tutorial/stats.dart.md ':include')

Estamos acessando o `StatsBloc` usando o `BlocProvider` e o `BlocBuilder` para reconstruir em resposta a alterações de estado no estado `StatsBloc`.

## Juntando tudo

Vamos criar o `main.dart` e o nosso widget TodosApp. Precisamos criar uma função `main` e executar nosso `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/main1.dart.md ':include')

?> **Nota:** Estamos configurando o delegate do nosso BlocSupervisor para o `SimpleBlocDelegate` que criamos anteriormente, para que possamos nos conectar a todas as transições e erros.

?> **Nota:** Também estamos envolvendo nosso widget `TodosApp` em um `BlocProvider` que gerencia a inicialização, o fechamento e o fornecimento de `TodosBloc` para toda a nossa árvore de widgets a partir de [flutter_bloc](https://pub.dev/packages/flutter_bloc). Nós adicionamos imediatamente o evento `TodosLoaded` para solicitar os mais recentes.

Em seguida, vamos implementar nosso widget `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/todos_app.dart.md ':include')

Nosso `TodosApp` é um `StatelessWidget` que acessa o `TodosBloc` fornecido através do `BuildContext`.

O `TodosApp` possui duas rotas:

- `Home` - que renderiza uma `HomeScreen`
- `TodoAdded` - que renderiza um `AddEditScreen` com `isEditing` definido como `false`.

O `TodosApp` também disponibiliza o `TabBloc`, `FilteredTodosBloc` e `StatsBloc` para os widgets em sua subárvore, usando o widget `MultiBlocProvider` do [flutter_bloc](https://pub.dev/packages/flutter_bloc) .

[multi_bloc_provider.dart](../_snippets/flutter_todos_tutorial/multi_bloc_provider.dart.md ':include')

é equivalente a escrever

[nested_bloc_providers.dart](../_snippets/flutter_todos_tutorial/nested_bloc_providers.dart.md ':include')

Você pode ver como o uso do MultiBlocProvider ajuda a reduzir os níveis de aninhamento e facilita a leitura e a manutenção do código.

Todo o `main.dart` deve ficar assim:

[main.dart](../_snippets/flutter_todos_tutorial/main2.dart.md ':include')

Isso é tudo! Agora, implementamos com sucesso um aplicativo de Todos no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito nossa camada de apresentação de nossa lógica de negócios.

O código fonte completo deste exemplo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos).
