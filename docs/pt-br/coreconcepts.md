# Principais Conceitos

?> Por favor leia e compreenda cuidadosamente as seções a seguir antes de trabalhar com [bloc](https://pub.dev/packages/bloc).

Existem vários conceitos essenciais que são críticos para entender como usar o Bloc.

Nas próximas seções, discutiremos cada uma delas em detalhes, bem como trabalharemos como elas se aplicariam a um aplicativo do mundo real: um aplicativo de contador.

## Eventos

> Eventos são a entrada para um bloc. Eles são geralmente adicionados em resposta a interações do usuário, como pressionar botões ou eventos do ciclo de vida, como carregamentos de páginas.

Ao projetar um aplicativo, precisamos dar um passo atrás e definir como os usuários irão interagir com ele. No contexto do nosso aplicativo de contador, teremos dois botões para aumentar e diminuir nosso contador.

Quando um usuário toca em um desses botões, algo precisa acontecer para notificar os "cérebros" do nosso aplicativo, para que ele possa responder à entrada do usuário; é aqui que os eventos entram em cena.

Precisamos ser capazes de notificar os "cérebros" de nossos aplicativos sobre um incremento e um decremento, portanto, precisamos definir esses eventos.

[counter_event.dart](../_snippets/core_concepts/counter_event.dart.md ':include')

Nesse caso, podemos representar os eventos usando um `enum`, mas para casos mais complexos, pode ser necessário usar uma` classe`, especialmente se for necessário passar informações ao bloc.

Neste ponto, definimos o nosso primeiro evento! Observe que não usamos o Bloc de nenhuma maneira até agora e não há mágica acontecendo; é apenas código Dart simples.

## States

> Os estados são a saída de um bloc e representam uma parte do estado do seu aplicativo. Os componentes da interface do usuário podem ser notificados sobre os estados e redesenhar partes deles com base no estado atual.

Até agora, definimos os dois eventos aos quais nosso aplicativo responderá: `CounterEvent.increment` e `CounterEvent.decrement`.

Agora precisamos definir como representar o estado do nosso aplicativo.

Como estamos construindo um contador, nosso estado é muito simples: é apenas um número inteiro que representa o valor atual do contador.

Veremos exemplos mais complexos de estado posteriormente, mas, neste caso, um tipo primitivo é perfeitamente adequado como representação de estado.

## Transições

> A mudança de um estado para outro é chamada de transição. Uma transição consiste no estado atual, no evento e no próximo estado.

À medida que o usuário interage com o nosso aplicativo de contador, eles acionam os eventos `Increment` e `Decrement` que atualizarão o estado do contador. Todas essas mudanças de estado podem ser descritas como uma série de `Transições`.

Por exemplo, se um usuário abrisse nosso aplicativo e tocasse no botão de incremento, veríamos a seguinte `Transição`.

[counter_increment_transition.json](../_snippets/core_concepts/counter_increment_transition.json.md ':include')

Como todas as alterações de estado são registradas, somos capazes de instrumentar com facilidade nossos aplicativos e rastrear todas as interações do usuário e alterações de estado em um único local. Além disso, isso possibilita coisas como depuração de viagens no tempo.

## Streams

Confira a documentação oficial [Documentação Dart](https://dart.dev/tutorials/language/streams) para mais informações sobre `Streams`.

> Um fluxo é uma sequência de dados assíncronos.

Para usar o Bloc, é essencial ter uma sólida compreensão de `Streams` e como elas funcionam.

> Se você não estiver familiarizado com o `Streams`, pense em um cano com água fluindo através dele. O tubo é a `Stream` e a água são os dados assíncronos.

Podemos criar uma `Stream` no Dart escrevendo uma função `async*`.

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

Marcando uma função como `async*`, podemos usar a palavra-chave `yield` e retornar um `fluxo` de dados. No exemplo acima, estamos retornando uma `Stream` de números inteiros até o parâmetro inteiro `max`.

Toda vez que "produzimos" em uma função `async*`, estamos enviando esse dado através da `Stream`.

Podemos consumir a `Stream` acima de várias maneiras. Se quiséssemos escrever uma função para retornar a soma de uma `Stream` de números inteiros, poderia ser algo como:

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

Ao marcar a função acima como `async`, podemos usar a palavra-chave `await` e retornar um `Future` de números inteiros. Neste exemplo, estamos aguardando cada valor da Stream e retornando a soma de todos os números inteiros.

Podemos juntar tudo assim:

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

## Blocs

> Um Bloc (Business Logic Component - componente da lógica de negócios) é um componente que converte uma `Stream` de `eventos` recebidos em uma `Stream` de `estados` de saída. Pense em um bloc como sendo os "cérebros" descritos acima.

> Todo bloc deve estender a classe base do bloc, que faz parte do pacote principal do bloc.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_class.dart.md ':include')

No trecho de código acima, estamos declarando nosso `CounterBloc` como um Bloc que converte` CounterEvents` em `ints`.

> Todo Bloc deve definir um estado inicial que é o estado antes que qualquer evento seja recebido.

Nesse caso, queremos que nosso contador comece com `0`.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_initial_state.dart.md ':include')

> Todo Bloc deve implementar uma função chamada `mapEventToState`. A função aceita o `evento` recebido como argumento e deve retornar uma `Stream` de novos `estados` que são consumidos pela camada de apresentação. Podemos acessar o estado atual do Bloc a qualquer momento usando a propriedade `state`.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_map_event_to_state.dart.md ':include')

Neste ponto, temos um `CounterBloc` em pleno funcionamento.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

Blocs ignoram estados duplicados. Se um bloc produzir `State nextState` onde` state == nextState`, nenhuma transição ocorrerá e nenhuma alteração será feita no `Stream <State>`.

Neste ponto, você provavelmente está se perguntando _"Como notifico um Bloc de um evento?"_.

Todo Bloc tem um método `add`. O `Add` pega um `event` e dispara o `mapEventToState`. O `Add` pode ser chamado a partir da camada de apresentação ou de dentro do Bloc e notifica o bloc de um novo `evento`.

Podemos criar uma aplicação simples que conta de 0 a 3.

[main.dart](../_snippets/core_concepts/counter_bloc_main.dart.md ':include')

!> Por padrão, os eventos sempre serão processados ​​na ordem em que foram adicionados e quaisquer eventos adicionados recentemente são enfileirados. Um evento é considerado totalmente processado após a conclusão da execução do `mapEventToState`.

As `Transições` no trecho de código acima seriam

[counter_bloc_transitions.json](../_snippets/core_concepts/counter_bloc_transitions.json.md ':include')

Infelizmente, no estado atual, não poderemos ver nenhuma dessas transições a menos que substituamos `onTransition`.

> `onTransition` é um método que pode ser substituído para lidar com todas as `Transition` do Bloc locais. O `onTransition` é chamado logo antes do `State` de um bloc ser atualizado.

?> **Dica**: `onTransition` é um ótimo local para adicionar log de informações do Bloc / informações analíticas

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

Agora que substituímos o `onTransition`, podemos fazer o que quisermos sempre que ocorrer uma `Transition`.

Assim como podemos lidar com `Transitions` no nível do Bloc, também podemos lidar com `Exceptions`.

> `onError` é um método que pode ser substituído para lidar com todas as `Exceptions` do Bloc local. Por padrão, todas as exceções serão ignoradas e a funcionalidade do `Bloc` não será afetada.

?> **Nota**: O argumento stackTrace pode ser `null` se o fluxo de estados recebeu um erro sem um `StackTrace`.

?> **Dica**: `onError` é um ótimo local para adicionar manipulação de erro específica de bloc.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

Agora que substituímos o `onError`, podemos fazer o que quisermos sempre que uma `Exception` for lançada.

## BlocObserver

Um bônus adicional ao usar o Bloc é que podemos ter acesso a todas as `Transitions` em um só lugar. Embora neste aplicativo tenha apenas um Bloc, é bastante comum em aplicativos maiores ter muitos Blocs gerenciando diferentes partes do estado do aplicativo.

Se quisermos fazer algo em resposta a todas as `Transitions`, podemos simplesmente criar nosso próprio` BlocObserver`.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer.dart.md ':include')

?> **Nota**: Tudo o que precisamos fazer é estender o `BlocObserver` e substituir o método` onTransition`.

Para dizer ao Bloc para usar nosso `SimpleBlocObserver`, precisamos apenas ajustar nossa função `main`.

[main.dart](../_snippets/core_concepts/simple_bloc_observer_main.dart.md ':include')

Se quisermos fazer algo em resposta a todos os `Events` adicionados, também podemos substituir o método `onEvent` no nosso `SimpleBlocObserver`.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

Se quisermos fazer algo em resposta a todas as `Exceptions` lançadas em um Bloc, também podemos substituir o método `onError` em nosso `SimpleBlocObserver`.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_complete.dart.md ':include')