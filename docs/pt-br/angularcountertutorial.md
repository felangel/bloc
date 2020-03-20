# Tutorial Contador AngularDart

![iniciante](https://img.shields.io/badge/level-beginner-green.svg)

> No tutorial a seguir, criaremos um contador no AngularDart usando a biblioteca Bloc.

![demo](../assets/gifs/angular_counter.gif)

## Setup

Começaremos criando um novo projeto AngularDart com [stagehand](https://github.com/dart-lang/stagehand).

[script](../_snippets/angular_counter_tutorial/stagehand.sh.md ':include')

!> Ative o stagehand executando `pub global enable stagehand`

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por:

[pubspec.yaml](../_snippets/angular_counter_tutorial/pubspec.yaml.md ':include')

e instale todas as nossas dependências

[script](../_snippets/angular_counter_tutorial/install.sh.md ':include')

Nosso aplicativo de contador terá apenas dois botões para aumentar/diminuir o valor do contador e um elemento para exibir o valor atual. Vamos começar a projetar os `CounterEvents`.

## Counter Events

[counter_event.dart](../_snippets/angular_counter_tutorial/counter_event.dart.md ':include')

## Counter States

Como o estado do nosso contador pode ser representado por um número inteiro, não precisamos criar uma classe personalizada!

## Counter Bloc

[counter_bloc.dart](../_snippets/angular_counter_tutorial/counter_bloc.dart.md ':include')

?> **Nota**: Apenas a partir da declaração da classe, podemos dizer que o nosso `CounterBloc` aceitará o `CounterEvents` como números inteiros de entrada e saída.

## Counter App

Agora que temos o nosso `CounterBloc` totalmente implementado, podemos começar a criar nosso Componente de aplicativo AngularDart.

Nosso `app.component.dart` deve se parecer com:

[app.component.dart](../_snippets/angular_counter_tutorial/app_component.dart.md ':include')

e nosso `app.component.html` deve ter a seguinte aparência:

[app.component.html](../_snippets/angular_counter_tutorial/app_component.html.md ':include')

## Counter Page

Por fim, tudo o que resta é criar nosso componente Counter Page.

Nosso `counter_page_component.dart` deve se parecer com:

[counter_page_component.dart](../_snippets/angular_counter_tutorial/counter_page_component.dart.md ':include')

?> **Nota**: Podemos acessar a instância do `CounterBloc` usando o sistema de injeção de dependência do AngularDart. Como o registramos como um `Provedor`, o AngularDart pode resolver adequadamente o `CounterBloc`.

?> **Nota**: Estamos fechando o `CounterBloc` no `ngOnDestroy`.

?> **Nota**: Estamos importando o `BlocPipe` para que possamos usá-lo em nosso modelo.

Por fim, nosso `counter_page_component.html` deve se parecer com:

[counter_page_component.html](../_snippets/angular_counter_tutorial/counter_page_component.html.md ':include')

?> **Nota**: Estamos usando o `BlocPipe` para que possamos exibir nosso estado counterBloc conforme ele é atualizado.

É isso aí! Separamos nossa camada de apresentação da nossa camada de lógica de negócios. Nosso `CounterPageComponent` não faz ideia do que acontece quando um usuário pressiona um botão; apenas adiciona um evento para notificar o `CounterBloc`. Além disso, nosso `CounterBloc` não faz ideia do que está acontecendo com o estado (valor do contador); é simplesmente converter os `CounterEvents` em números inteiros.

Podemos executar nosso aplicativo com `webdev serve` e podemos visualizá-lo [localmente](http://localhost:8080).

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).
