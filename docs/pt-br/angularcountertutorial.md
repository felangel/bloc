# Tutorial Contador AngularDart

![iniciante](https://img.shields.io/badge/level-beginner-green.svg)

> No tutorial a seguir, criaremos um contador no AngularDart usando a biblioteca Bloc.

![demo](../assets/gifs/angular_counter.gif)

## Setup

Começaremos criando um novo projeto AngularDart com [stagehand](https://github.com/dart-lang/stagehand).

```bash
stagehand web-angular
```

!> Ative o stagehand executando `pub global enable stagehand`

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por:

```yaml
name: angular_counter
description: A web app that uses angular_bloc

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  angular: ^5.3.0
  angular_components: ^0.13.0
  angular_bloc: ^3.0.0

dev_dependencies:
  angular_test: ^2.0.0
  build_runner: ">=1.6.2 <2.0.0"
  build_test: ^0.10.2
  build_web_compilers: ">=1.2.0 <3.0.0"
  test: ^1.0.0
```

e instale todas as nossas dependências

```bash
pub get
```

Nosso aplicativo de contador terá apenas dois botões para aumentar/diminuir o valor do contador e um elemento para exibir o valor atual. Vamos começar a projetar os `CounterEvents`.

## Counter Events

```dart
enum CounterEvent { increment, decrement }
```

## Counter States

Como o estado do nosso contador pode ser representado por um número inteiro, não precisamos criar uma classe personalizada!

## Counter Bloc

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

?> **Nota**: Apenas a partir da declaração da classe, podemos dizer que o nosso `CounterBloc` aceitará o `CounterEvents` como números inteiros de entrada e saída.

## Counter App

Agora que temos o nosso `CounterBloc` totalmente implementado, podemos começar a criar nosso Componente de aplicativo AngularDart.

Nosso `app.component.dart` deve se parecer com:

```dart
import 'package:angular/angular.dart';

import 'package:angular_counter/src/counter_page/counter_page_component.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: [CounterPageComponent],
)
class AppComponent {}
```

e nosso `app.component.html` deve ter a seguinte aparência:

```html
<counter-page></counter-page>
```

## Counter Page

Por fim, tudo o que resta é criar nosso componente Counter Page.

Nosso `counter_page_component.dart` deve se parecer com:

```dart
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:angular_bloc/angular_bloc.dart';

import './counter_bloc.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  styleUrls: ['counter_page_component.css'],
  directives: [MaterialFabComponent],
  providers: [ClassProvider(CounterBloc)],
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnDestroy {
  final CounterBloc counterBloc;

  CounterPageComponent(this.counterBloc) {}

  @override
  void ngOnDestroy() {
    counterBloc.close();
  }

  void increment() {
    counterBloc.add(CounterEvent.increment);
  }

  void decrement() {
    counterBloc.add(CounterEvent.decrement);
  }
}
```

?> **Nota**: Podemos acessar a instância do `CounterBloc` usando o sistema de injeção de dependência do AngularDart. Como o registramos como um `Provedor`, o AngularDart pode resolver adequadamente o `CounterBloc`.

?> **Nota**: Estamos fechando o `CounterBloc` no `ngOnDestroy`.

?> **Nota**: Estamos importando o `BlocPipe` para que possamos usá-lo em nosso modelo.

Por fim, nosso `counter_page_component.html` deve se parecer com:

```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterBloc | bloc }}</h2>
  <material-fab class="counter-fab-button" (trigger)="increment()"
    >+</material-fab
  >
  <material-fab class="counter-fab-button" (trigger)="decrement()"
    >-</material-fab
  >
</div>
```

?> **Nota**: Estamos usando o `BlocPipe` para que possamos exibir nosso estado counterBloc conforme ele é atualizado.

É isso aí! Separamos nossa camada de apresentação da nossa camada de lógica de negócios. Nosso `CounterPageComponent` não faz ideia do que acontece quando um usuário pressiona um botão; apenas adiciona um evento para notificar o `CounterBloc`. Além disso, nosso `CounterBloc` não faz ideia do que está acontecendo com o estado (valor do contador); é simplesmente converter os `CounterEvents` em números inteiros.

Podemos executar nosso aplicativo com `webdev serve` e podemos visualizá-lo [localmente](http://localhost:8080).

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).
