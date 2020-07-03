# Principais Conceitos do Flutter Bloc

?> Por favor leia e compreenda cuidadosamente as seções a seguir antes de trabalhar com [bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** é um widget Flutter que requer uma função `Bloc` e `builder`. O BlocBuilder trata da construção do widget em resposta a novos estados. O `BlocBuilder` é muito semelhante ao` StreamBuilder`, mas possui uma API mais simples para reduzir a quantidade de código padrão necessário. A função `builder` será potencialmente chamada muitas vezes e deve ser uma [função pura] (https://en.wikipedia.org/wiki/Pure_function) que retorna um widget em resposta ao estado.

Veja `BlocListener` se você quiser "fazer" qualquer coisa em resposta a alterações de estado, como navegação, exibição de um diálogo, etc ...

Se o parâmetro bloc for omitido, o `BlocBuilder` executará automaticamente uma pesquisa usando o` BlocProvider` e o atual `BuildContext`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Especifique o Bloc apenas se você deseja fornecer um Bloc que terá o escopo definido em um único widget e não possa ser acessado através do pai `BlocProvider` e do atual` BuildContext`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Se você deseja um controle refinado sobre quando a função do construtor é chamada, você pode fornecer uma condição opcional ao `BlocBuilder`. A condição pega o estado anterior do bloc e o atual estado do bloc e retorna um valor booleano. Se `buildWhen` retornar true,`builder` será chamado com `state` e o widget será reconstruído. Se `buildWhen` retornar false, o `builder` não será chamado com `state` e nenhuma reconstrução ocorrerá.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** é um widget Flutter que fornece um Bloc para seus filhos via `BlocProvider.of<T>(context)`. Ele é usado como um widget de injeção de dependência (DI) para que uma única instância de um Bloc possa ser fornecida a vários widgets em uma subárvore.

Na maioria dos casos, o `BlocProvider` deve ser usado para criar novos `blocs`, que serão disponibilizados para o restante da subárvore. Nesse caso, como o BlocProvider é responsável pela criação do bloc, ele automaticamente tratará do fechamento do bloc.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

Em alguns casos, o BlocProvider pode ser usado para fornecer um bloc existente para uma nova parte da árvore de widgets. Isso será mais comumente usado quando um bloc existente precisar ser disponibilizado para uma nova rota. Nesse caso, o `BlocProvider` não fechará o bloc automaticamente, pois não o criou.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

então, a partir de `ChildA` ou` ScreenA`, podemos recuperar o `BlocA` com:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider** é um widget Flutter que mescla vários widgets `BlocProvider` em um.
O `MultiBlocProvider` melhora a legibilidade e elimina a necessidade de aninhar vários` BlocProviders`.
Usando o `MultiBlocProvider`, podemos ir de:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

para:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** é um widget Flutter que pega um `BlocWidgetListener` e um `Bloc` opcional e invoca o `listener` em resposta a alterações de estado no bloc. Deve ser usado para funcionalidades que precisam ocorrer uma vez por alteração de estado, como navegação, mostrar um `SnackBar`, mostrar um` Diálogo`, etc ...

`listener` é chamado apenas uma vez para cada alteração de estado (**NÃO** incluindo` initialState`), diferente do `builder` no` BlocBuilder` e é uma função `void`.

Se o parâmetro bloc for omitido, o `BlocListener` executará automaticamente uma pesquisa usando o` BlocProvider` e o atual `BuildContext`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Especifique o bloc apenas se desejar fornecer um bloc que, de outra forma, não poderá ser acessado via `BlocProvider` e pelo atual` BuildContext`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Se você deseja um controle refinado sobre quando a função listener é chamada, você pode fornecer uma condição opcional ao` BlocListener`. A condição pega o estado anterior do bloc e o atual estado do bloc e retorna um valor booleano. Se `listenWhen` retornar true,` listener` será chamado com `state`. Se `listenWhen` retornar falso,`listener` não será chamado com `state`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener** é um widget Flutter que mescla vários widgets `BlocListener` em um.
O `MultiBlocListener` melhora a legibilidade e elimina a necessidade de aninhar vários` BlocListeners`.
Usando o `MultiBlocListener`, podemos ir de:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

para:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer** expõe um `construtor` e um` ouvinte` para reagir a novos estados. `BlocConsumer` é análogo a um` BlocListener` e `BlocBuilder` aninhado, mas reduz a quantidade de clichê necessária. O `BlocConsumer` deve ser usado apenas quando for necessário reconstruir a interface do usuário e executar outras reações às alterações de estado no` bloc`. O `BlocConsumer` pega um` BlocWidgetBuilder` e `BlocWidgetListener` necessário e um `bloc` opcional, `BlocBuilderCondition` e `BlocListenerCondition`.

Se o parâmetro `bloc` for omitido, o `BlocConsumer` executará automaticamente uma pesquisa usando
`BlocProvider` e o atual `BuildContext`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

Um opcional `listenWhen` e` buildWhen` podem ser implementados para um controle mais granular sobre quando `listener` e `builder` são chamados. O `listenWhen` e o `buildWhen` serão invocados em cada alteração de estado do `bloc`. Cada um deles assume o `state` anterior e o atual` state` e deve retornar um `bool` que determina se a função` builder` e / ou `listener` será ou não invocada. O `state` anterior será inicializado com o` state` do `bloc` quando o` BlocConsumer` for inicializado. `listenWhen` e `buildWhen` são opcionais e, se não forem implementados, serão padronizados como `true`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** é um widget Flutter que fornece um repositório para seus filhos via `RepositoryProvider.of<T>(context)`. Ele é usado como um widget de injeção de dependência (DI) para que uma única instância de um repositório possa ser fornecida a vários widgets em uma subárvore. O `BlocProvider` deve ser usado para fornecer blocs, enquanto o` RepositoryProvider` deve ser usado apenas para repositórios.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

então, no `ChildA`, podemos recuperar a instância do` Repository` com:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider** é um widget Flutter que mescla vários widgets `RepositoryProvider` em um.
O `MultiRepositoryProvider` melhora a legibilidade e elimina a necessidade de aninhar vários `RepositoryProvider`.
Usando o `MultiRepositoryProvider`, podemos ir de:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

para:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Uso

Vamos dar uma olhada em como usar o `BlocBuilder` para conectar um widget da `CounterPage` a um `CounterBloc`.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

Nesse ponto, separamos com êxito nossa camada de apresentação da nossa camada de lógica de negócios. Observe que o widget `CounterPage` não sabe nada sobre o que acontece quando um usuário toca nos botões. O widget simplesmente diz ao `CounterBloc` que o usuário pressionou o botão de incremento ou decremento.
