# Tutorial Flutter Counter

![iniciante](https://img.shields.io/badge/level-beginner-green.svg)

> No tutorial a seguir, criaremos um contador no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Setup

Começaremos criando um novo projeto Flutter

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

e instale todas as nossas dependências

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Nosso aplicativo de contador terá apenas dois botões para aumentar / diminuir o valor do contador e um widget `Text` para exibir o valor atual. Vamos começar a projetar os `CounterEvents`.

## Eventos Counter

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Estados Counter

Como o estado do nosso contador pode ser representado por um número inteiro, não precisamos criar uma classe personalizada!

## Counter Bloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Nota**: Apenas a partir da declaração da classe, podemos dizer que o nosso `CounterBloc` aceitará o` CounterEvents` como números inteiros de entrada e saída.

## Counter App

Agora que temos nosso `CounterBloc` totalmente implementado, podemos começar a criar nosso aplicativo Flutter.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Nota**: Estamos usando o widget `BlocProvider` do `flutter_bloc` para tornar a instância do `CounterBloc` disponível para toda a subárvore (`CounterPage`). O `BlocProvider` também controla o fechamento do `CounterBloc` automaticamente, para que não seja necessário usar um `StatefulWidget`.

## Counter Page

Finalmente, tudo o que resta é criar nossa página de contador.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Nota**: Podemos acessar a instância do `CounterBloc` usando o `BlocProvider.of<CounterBloc>(context)` porque envolvemos nossa `CounterPage` em um `BlocProvider`.

?> **Nota**: Estamos usando o widget `BlocBuilder` do `flutter_bloc` para reconstruir nossa interface do usuário em resposta a alterações de estado (alterações no valor do contador).

?> **Nota**: `BlocBuilder` usa um parâmetro opcional `bloc`, mas podemos especificar o tipo do blocc e o tipo do estado, e o `BlocBuilder` encontrará o bloc automaticamente, assim não precisamos explicitar use `BlocProvider.of<CounterBloc>(context)`.

!> Especifique apenas o bloc no `BlocBuilder` se desejar fornecer um bloc com escopo definido para um único widget e que não possa ser acessado pelo pai` BlocProvider` e pelo atual `BuildContext`.

É isso aí! Separamos nossa camada de apresentação da nossa camada de lógica de negócios. Nossa `CounterPage` não faz ideia do que acontece quando um usuário pressiona um botão; apenas adiciona um evento para notificar o `CounterBloc`. Além disso, nosso `CounterBloc` não faz ideia do que está acontecendo com o estado (valor do contador); é simplesmente converter os `CounterEvents` em números inteiros.

Podemos executar nosso aplicativo com `flutter run` e podemos vê-lo em nosso dispositivo ou simulador / emulador.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
