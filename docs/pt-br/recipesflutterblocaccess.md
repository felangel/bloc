# Receita: Acesso ao Bloc

> Nesta receita, veremos como usar o BlocProvider para tornar um bloc acessível em toda a árvore de widgets. Vamos explorar três cenários: acesso local, acesso à rota e acesso global.

## Accesso Local

> Neste exemplo, vamos usar o BlocProvider para disponibilizar um bloc para uma subárvore local. Nesse contexto, local significa dentro de um contexto em que não há rotas sendo empurradas / estouradas.

### Bloc

Por uma questão de simplicidade, usaremos um `Counter` como nosso aplicativo de exemplo.

Nossa implementação do `CounterBloc` será parecida com:

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Teremos três partes em nossa interface do usuário:

- App: o widget do aplicativo raiz
- CounterPage: o widget Container que gerencia o `CounterBloc` e expõe o` FloatingActionButtons` ao `incremento` e `decrementa` o contador.
- CounterText: um widget de texto responsável por exibir a contagem atual.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/local_access/main.dart.md ':include')

Nosso widget `App` é um `StatelessWidget` que usa um `MaterialApp` e define nosso` CounterPage` como o widget inicial. O widget `App` é responsável por criar e fechar o `CounterBloc`, além de disponibilizá-lo à `CounterPage` usando um `BlocProvider`.

?>**Nota:** Quando envolvemos um widget com `BlocProvider`, podemos fornecer um bloc para todos os widgets dentro dessa subárvore. Nesse caso, podemos acessar o `CounterBloc` de dentro do widget `CounterPage` e quaisquer filhos do widget `CounterPage` usando o `BlocProvider.of <CounterBloc> (context)`.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_page.dart.md ':include')

O widget `CounterPage` é um` StatelessWidget` que acessa o `CounterBloc` através do` BuildContext`.

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_text.dart.md ':include')

Nosso widget `CounterText` está usando um `BlocBuilder` para se reconstruir sempre que o estado do `CounterBloc` mudar. Utilizamos `BlocProvider.of <CounterBloc> (context)` para acessar o CounterBloc fornecido e retornar um widget `Text` com a contagem atual.

Isso envolve a parte de acesso ao bloc local desta receita e o código fonte completo pode ser encontrado [aqui](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

A seguir, veremos como fornecer um bloc em várias páginas / rotas.

## Accesso a Rotas Anônimas

> Neste exemplo, vamos usar o `BlocProvider` para acessar um bloc através das rotas. Quando uma nova rota é adicionada, ela terá um `BuildContext` diferente, que não possui mais uma referência aos blocs fornecidos anteriormente. Como resultado, temos que agrupar a nova rota em um `BlocProvider` separado.

### Bloc

Novamente, vamos usar o `CounterBloc` para simplificar.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Novamente, teremos três partes na interface do usuário do nosso aplicativo:

- App: o widget do aplicativo raiz
- HomePage: o widget Container que gerencia o `CounterBloc` e expõe o `FloatingActionButtons` ao `incremento` e `decrementa` o contador.
- CounterPage: um widget responsável por exibir a `contagem atual` como uma rota separada.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/main.dart.md ':include')

Novamente, nosso widget `App` é o mesmo de antes.

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/home_page.dart.md ':include')

A `HomePage` é semelhante à `CounterPage` no exemplo acima; no entanto, em vez de renderizar um widget `CounterText`, ele renderiza um `RaisedButton` no centro, o que permite ao usuário navegar para uma nova tela que exibe a contagem atual.

Quando o usuário toca no `RaisedButton`, adicionamos uma nova `MaterialPageRoute` e retornamos o `CounterPage`; no entanto, estamos agrupando o `CounterPage` em um `BlocProvider` para disponibilizar a instância atual do `CounterBloc` na próxima página.

!> É fundamental que estejamos usando o construtor de valor do `BlocProvider` neste caso, porque estamos fornecendo uma instância existente do `CounterBloc`. O construtor de valor do `BlocProvider` deve ser usado apenas nos casos em que desejamos fornecer um bloc existente para uma nova subárvore. Além disso, o uso do construtor value não fechará o bloc automaticamente, o que, neste caso, é o que queremos (já que ainda precisamos do `CounterBloc` para funcionar nos widgets ancestrais). Em vez disso, simplesmente passamos o `CounterBloc` existente para a nova página como um valor existente, em oposição a um construtor. Isso garante que o único `BlocProvider` de nível superior lide com o fechamento do `CounterBloc` quando não for mais necessário.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/counter_page.dart.md ':include')

O `CounterPage` é um `StatelessWidget` super super simples que usa o `BlocBuilder` para renderizar novamente um widget `Text` com a contagem atual. Assim como antes, somos capazes de usar o `BlocProvider.of <CounterBloc> (context)` para acessar o `CounterBloc`.

É tudo o que existe neste exemplo e o código fonte completo pode ser encontrado [aqui](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

A seguir, veremos como definir o escopo de um bloc para apenas uma ou mais rotas nomeadas.

## Acesso a Rotas Nomeadas

> Neste exemplo, vamos usar o BlocProvider para acessar um bloc através de várias rotas nomeadas. Quando uma nova rota nomeada é enviada, ela terá um `BuildContext` diferente (como antes), que não possui mais uma referência aos blocs fornecidos anteriormente. Nesse caso, vamos gerenciar os blocs que queremos escopar no widget pai e fornecê-los seletivamente para as rotas que devem ter acesso.

### Bloc

Novamente, vamos usar o `CounterBloc` para simplificar.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Novamente, teremos três partes na interface do usuário do nosso aplicativo:

- App: o widget raiz do aplicativo
- HomePage: o widget container que gerencia o `CounterBloc` e expõe `FloatingActionButtons` ao `increment` e `decrement` do contador.
- CounterPage: um widget responsável por exibir a `contagem` atual como uma rota separada.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/main.dart.md ':include')

Nosso widget `App` é responsável por gerenciar a instância do `CounterBloc` que forneceremos para as rotas raiz (`/`) e counter (`/counter`).

!> É essencial entender que, como o `_AppState` está criando a instância do `CounterBloc`, ele também deve fechá-la em seu método `dispose`.

!> Estamos usando o `BlocProvider.value` ao fornecer a instância do `CounterBloc` para as rotas, porque não queremos que o `BlocProvider` lide com o dispose do bloc (já que o `_AppState` é responsável por isso).

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/home_page.dart.md ':include')

A `HomePage` é semelhante à `CounterPage` no exemplo acima; no entanto, em vez de renderizar um widget `CounterText`, ele renderiza um `RaisedButton` no centro, o que permite ao usuário navegar para uma nova tela que exibe a contagem atual.

Quando o usuário toca no `RaisedButton`, empurramos uma nova rota nomeada para navegar até a rota `/counter` que definimos acima.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/counter_page.dart.md ':include')

O `CounterPage` é um `StatelessWidget` super super simples que usa o `BlocBuilder` para renderizar novamente um widget `Text` com a contagem atual. Assim como antes, somos capazes de usar o `BlocProvider.of<CounterBloc>(context)` para acessar o `CounterBloc`.

Isso é tudo neste exemplo e o código fonte completo pode ser encontrado [aqui](https://gist.github.com/felangel/8d143cf3b7da38d80de4bcc6f65e9831).

## Accesso Global

> Neste último exemplo, demonstraremos como disponibilizar uma instância de bloc para toda a árvore de widgets. Isso é útil para casos específicos como um `AuthenticationBloc` ou` ThemeBloc` porque esses estados se aplicam a todas as partes do aplicativo.

### Bloc

Como sempre, vamos usar o `CounterBloc` como nosso exemplo de simplicidade.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Vamos seguir a mesma estrutura de aplicativo do exemplo "Acesso local". Como resultado, teremos três partes em nossa interface:

- App: o widget do aplicativo raiz que gerencia a instância global do nosso `CounterBloc`.
- CounterPage: o widget Container que expõe `FloatingActionButtons` para `incrementar` e `decrementar` o contador.
- CounterText: um widget de texto responsável por exibir a contagem atual.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/global_access/main.dart.md ':include')

Assim como no exemplo de acesso local acima, o `App` gerencia criando, fechando e fornecendo o `CounterBloc` para a subárvore usando o `BlocProvider`. A principal diferença está neste caso, `MaterialApp` é filho do `BlocProvider`.

Envolvendo todo o `MaterialApp` em um `BlocProvider` é a chave para tornar nossa instância do `CounterBloc` acessível globalmente. Agora podemos acessar nosso `CounterBloc` de qualquer lugar em nosso aplicativo, onde temos um `BuildContext` usando `BlocProvider.of <CounterBloc> (context);`

?> **Nota:** Essa abordagem ainda funciona se você estiver usando um `CupertinoApp` ou `WidgetsApp`.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_page.dart.md ':include')

Nosso `CounterPage` é um `StatelessWidget` porque não precisa gerenciar nada do seu próprio estado. Assim como mencionamos acima, ele usa o `BlocProvider.of <CounterBloc> (context)` para acessar a instância global do `CounterBloc`.

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_text.dart.md ':include')

Nada de novo aqui; o widget `CounterText` é o mesmo que no primeiro exemplo. É apenas um `StatelessWidget` que usa um `BlocBuilder` para renderizar novamente quando o estado do `CounterBloc` muda e acessa a instância global do `CounterBloc` usando o `BlocProvider.of <CounterBloc> (context)`.

Isso é tudo! O código fonte completo pode ser encontrado [aqui](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).
