# Tutorial Contador Flutter

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> No seguinte tutorial, iremos construir um Contador em Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Configuração

Começaremos criando um projeto Flutter novo.

```sh
flutter create flutter_counter
```

Primeiramente, começaremos substituindo o `pubspec.yaml` com o seguinte

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/pubspec.yaml ':include')

e então, instalamos nossas depedências

```sh
flutter packages get
```

## BlocObserver

A primiera coisa que vamos olhar é como criar um `BlocObserver` no qual irá nos ajudar a observar todas as mudanças de estado na aplicação.

Vamos criar um `lib/counter_observer.dart`:

[counter_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter_observer.dart ':include')

Nesse caso, estamos somente sobrescrevendo o metodo `onChange` para que possamos ver todas as mudanças ocorridas

?> **Nota**: o metodo `onChange` funciona da mesma forma tanto para instâncias de `Bloc` quanto para `Cubit`.

## main.dart

Agora, vamos substituir o conteúdo de `main.dart` com:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/main.dart ':include')

Estamos inicializando `CounterObserver` que acabamos de criar e chamando o metodo `runApp` com o widget `CounterApp` que nós veremos a seguir. 

## Counter App

`CounterApp` será um `MaterialApp` e está especificando a `home` como a classe `CounterPage`.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/app.dart ':include')

?> **Nota**: Estamos extendendo o método `MaterialApp` porque a classe `CounterApp` _é_ um `MaterialApp`. Na maioria dos casos, estaremos criando instâncias  `StatelessWidget` ou `StatefulWidget` em fazendo composição de widgets na `build` mas nesse caso, não há widgets para compor, então é simples somente extender `MaterialApp`.

Vamos dar uma olhada na `CounterPage` agora!

## Counter Page

O widget `CounterPage` é responsável por criar um `CounterCubit` (na qual veremos adiante) e passando-o para o  `CounterView`.

[counter_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_page.dart ':include')

?> **Nota**: É importante separar ou desacoplar a criação de um `Cubit` do consumo de um `Cubit` para que temos um código muito mais testável e reusável.

## Counter Cubit

A classe `CounterCubit` vai expor dois métodos:

- `increment`: adiciona 1 para o estado atual
- `decrement`: subtrai 1 do estado atual.

O tipo de estado que o `CounterCubit` está gerenciando é somente um `int` e o estado inicial é `0`.

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

?> **Dica**: Use o [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) para criar novos cubits automaticamente.

Agora, veremos o `CounterView` no qual sua responsabilidade será consumir o estado e interagir com o `CounterCubit`.

## Counter View

O `CounterView` é responsável por renderizar a conta atual (dos metodos que incrementam e decrementam) e renderizar os dois FloatingActionButtons para fazer o incremento/decremento do contador.

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

Um `BlocBuilder` é usado para cobrir o widget  `Text` para que ele atualize o texto qualquer hora que o estado do `CounterCubit` mudar. Também, `context.read<CounterCubit>()` é usado para verificar a intância mais próxima de um `CounterCubit`.

?> **Nota**: Somente o widget `Text` é envolto em um `BlocBuilder` Porque esse é o único widget que precisa ser redesenhado em resposta a mudanças de estado no `CounterCubit`. Evite cobrir seus widgets desnecessariamente se eles não precisam ser redesenhados quando há uma mudança de estado.

É isso! Nos separamos a camada de apresentação da camada da lógica de negócios. O `CounterView` não tem ideia do que acontece quando o usuário pressiona um botão; ele somente notifica o `CounterCubit`. Ademais, o `CounterCubit` não faz ideia do que está acontecendo com o estado (valor do contador); ele somente está emitindo estados em resposta à chamada do método.

Nos podemos iniciar nosso aplicativo com `flutter run` e ver no nosso dispositivo ou simulador/emulador.

A fonte completa (incluindo testes de unidade e de widgets) para esse exemplo podem ser vistas [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter).
