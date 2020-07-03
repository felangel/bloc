# Tutorial Flutter Timer

![iniciante](https://img.shields.io/badge/level-beginner-green.svg)

> No tutorial a seguir, abordaremos como criar um aplicativo de timer usando a biblioteca bloc. O aplicativo final deve ter a seguinte aparência:

![demo](../assets/gifs/flutter_timer.gif)

## Setup

Vamos começar criando um novo projeto Flutter

[script](../_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

Em seguida, podemos substituir o conteúdo de pubspec.yaml por:

[pubspec.yaml](../_snippets/flutter_timer_tutorial/pubspec.yaml.md ':include')

?> **Nota:** Estaremos utilizando o [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable), e [wave](https://pub.dev/packages/wave) neste app.

Em seguida, execute o `flutter packages get` para instalar todas as dependências.

## Ticker

> The ticker will be our data source for the timer application. It will expose a stream of ticks which we can subscribe and react to.

Comece criando `ticker.dart`.

[ticker.dart](../_snippets/flutter_timer_tutorial/ticker.dart.md ':include')

Tudo o que a classe `Ticker` faz é expor uma função de tick que leva o número de ticks (segundos) que queremos e retorna um fluxo que emite os segundos restantes a cada segundo.

Em seguida, precisamos criar nosso `TimerBloc` que consumirá o `Ticker`.

## Timer Bloc

### TimerState

Começaremos definindo os `TimerStates` nos quais nosso `TimerBloc` pode estar.

Nosso estado `TimerBloc` pode ser um dos seguintes:

- TimerInitial - pronto para começar a contagem regressiva a partir da duração especificada.
- TimerRunInProgress - contando ativamente a duração especificada.
- TimerRunPause - pausado com a duração restante.
- TimerRunComplete - concluído com uma duração restante de 0.

Cada um desses estados terá implicações no que o usuário vê. Por exemplo:

- se o estado estiver `TimerInitial`, o usuário poderá iniciar o cronômetro.
- se o estado estiver `TimerRunInProgress`, o usuário poderá pausar e redefinir o timer, além de ver a duração restante.
- se o estado estiver em `TimerRunPause`, o usuário poderá retomar o cronômetro e redefinir o cronômetro.
- se o estado estiver `TimerRunComplete`, o usuário poderá redefinir o timer.

Para manter todos os nossos arquivos de bloc juntos, vamos criar um diretório de bloc com `bloc/timer_state.dart`..

?> **Dica:** Você pode usar o [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) para gerar estes arquivos para você.

[timer_state.dart](../_snippets/flutter_timer_tutorial/timer_state.dart.md ':include')

Observe que todos os `TimerStates` estendem a classe base abstrata `TimerState`, que possui uma propriedade duration. Isso ocorre porque, independentemente do estado do nosso `TimerBloc`, queremos saber quanto tempo resta.

Em seguida, vamos definir e implementar os `TimerEvents` que nosso `TimerBloc` processará.

### TimerEvent

Nosso `TimerBloc` precisará saber como processar os seguintes eventos:

- TimerStarted - informa ao TimerBloc que o timer deve ser iniciado.
- TimerPaused - informa ao TimerBloc que o cronômetro deve ser pausado.
- TimerResumed - informa o TimerBloc que o cronômetro deve ser reiniciado.
- TimerReset - informa ao TimerBloc que o timer deve ser redefinido para o estado original.
- TimerTicked - informa ao TimerBloc que um tick ocorreu e que ele precisa atualizar seu estado de acordo.

Se você não utiliza [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), então crie `bloc/timer_event.dart` e vamos implementar estes eventos.

[timer_event.dart](../_snippets/flutter_timer_tutorial/timer_event.dart.md ':include')

Em seguida, vamos implementar o `TimerBloc`!

### TimerBloc

Se você ainda não o fez, crie `bloc/timer bloc.dart` e crie um` TimerBloc` vazio.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_empty.dart.md ':include')

A primeira coisa que precisamos fazer é definir o `initialState` do nosso `TimerBloc`. Nesse caso, queremos que o `TimerBloc` inicie no estado `TimerInitial` com uma duração predefinida de 1 minuto (60 segundos).

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

Em seguida, precisamos definir a dependência do nosso `Ticker`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

Também estamos definindo um `StreamSubscription` para o nosso `Ticker`, o qual entraremos em breve.

Neste ponto, tudo o que resta a fazer é implementar o `mapEventToState`. Para melhorar a legibilidade, gosto de dividir cada manipulador de eventos em sua própria função auxiliar. Começaremos com o evento `TimerStarted`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

Se o `TimerBloc` receber um evento `TimerStarted`, ele empurra um estado `TimerRunInProgress` com a duração inicial. Além disso, se já havia um `_tickerSubscription` aberto, precisamos cancelá-lo para desalocar a memória. Também precisamos substituir o método `close` no nosso` TimerBloc` para que possamos cancelar o `_tickerSubscription` quando o `TimerBloc` for fechado. Por fim, ouvimos o fluxo `_ticker.tick` e, em cada tick, adicionamos um evento `TimerTicked` com a duração restante.

Em seguida, vamos implementar o manipulador de eventos `TimerTicked`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

Sempre que um evento `TimerTicked` é recebido, se a duração do tick for maior que 0, precisamos enviar um estado atualizado `TimerRunInProgress` com a nova duração. Caso contrário, se a duração do tiquetaque for 0, nosso cronômetro terminou e precisamos pressionar o estado `TimerRunComplete`.

Agora vamos implementar o manipulador de eventos `TimerPaused`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

Em `_mapTimerPausedToState`, se o `state` do nosso `TimerBloc` for `TimerRunInProgress`, poderemos pausar o `_tickerSubscription` e pressionar o estado de `TimerRunPause` com a duração atual do timer.

Em seguida, vamos implementar o manipulador de eventos `TimerResumed` para que possamos pausar o cronômetro.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

O manipulador de eventos `TimerResumed` é muito semelhante ao manipulador de eventos `TimerPaused`. Se o `TimerBloc` possui um `state` de `TimerRunPause` e recebe um eventoc`TimerResumed`, ele retoma o `_tickerSubscription` e empurra o estado de `TimerRunInProgress` com a duração atual.

Por fim, precisamos implementar o manipulador de eventos `TimerReset`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc.dart.md ':include')

Se o `TimerBloc` receber um evento `TimerReset`, ele precisará cancelar a atual `_tickerSubscription` para que não seja notificado de nenhum tique adicional e empurre o estado `TimerInitial` com a duração original.

Se você não utiliza [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), então crie `bloc/timer_event.dart` e vamos implementar estes eventos.

[bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_barrel.dart.md ':include')

Isso é tudo o que existe no "TimerBloc". Agora, tudo o que resta é implementar a interface do usuário para nosso aplicativo Timer.

## UI

### MyApp

Podemos começar excluindo o conteúdo de `main.dart` e criando nosso widget `MyApp`, que será a raiz do nosso aplicativo.

[main.dart](../_snippets/flutter_timer_tutorial/main1.dart.md ':include')

O `MyApp` é um` StatelessWidget` que gerenciará a inicialização e o fechamento de uma instância do `TimerBloc`. Além disso, está usando o widget `BlocProvider` para tornar nossa instância do `TimerBloc` disponível para os widgets da nossa subárvore.

Em seguida, precisamos implementar nosso widget `Timer`.

### Timer

Nosso widget `Timer` será responsável por exibir o tempo restante juntamente com os botões adequados que permitirão aos usuários iniciar, pausar e redefinir o timer.

[timer.dart](../_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

Até agora, estamos apenas usando o `BlocProvider` para acessar a instância do nosso `TimerBloc` e usando o widget `BlocBuilder` para reconstruir a interface do usuário toda vez que obtivermos um novo `TimerState`.

Em seguida, implementaremos nosso widget "Ações", que terá as ações adequadas (iniciar, pausar e redefinir).

### Actions

[actions.dart](../_snippets/flutter_timer_tutorial/actions.dart.md ':include')

O widget `Actions` é apenas outro `StatelessWidget` que usa o `BlocProvider` para acessar a instância do `TimerBloc` e, em seguida, retorna diferentes `FloatingActionButtons` com base no estado atual do` TimerBloc`. Cada um dos `FloatingActionButtons` adiciona um evento no retorno de chamada `onPressed` para notificar o `TimerBloc`.

Agora precisamos conectar o `Actions` ao nosso widget `Timer`.

[timer.dart](../_snippets/flutter_timer_tutorial/timer2.dart.md ':include')

Adicionamos outro `BlocBuilder` que renderizará o widget `Actions`; no entanto, desta vez, estamos usando um recurso recém-introduzido [flutter_bloc] (https://pub.dev/packages/flutter_bloc) para controlar a frequência com que o widget `Actions` é reconstruído (introduzido na` v0.15.0`).

Se você deseja um controle refinado sobre quando a função `builder` é chamada, você pode fornecer uma condição opcional ao `BlocBuilder`. A condição pega o estado anterior do bloc e o estado atual do bloc e retorna um `booleano`. Se `condition` retornar `true`, o `builder` será chamado com` state` e o widget será reconstruído. Se `condition` retornar `false`, o `builder` não será chamado com `state` e nenhuma reconstrução ocorrerá.

Nesse caso, não queremos que o widget "Actions" seja reconstruído a cada tick porque isso seria ineficiente. Em vez disso, queremos apenas que o `Actions` seja reconstruído se o `runtimeType` do `TimerState` mudar (TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, etc...).

Como resultado, se coloríssemos os widgets aleatoriamente em cada reconstrução, ficaria assim:

![BlocBuilder condition demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Note:** Mesmo que o widget `Text` seja reconstruído a cada tick, apenas reconstruímos as `Actions` se elas precisarem ser reconstruídas.

Por fim, precisamos adicionar o fundo da onda super legal usando o pacote [wave](https://pub.dev/packages/wave).

### Background com Waves 

[background.dart](../_snippets/flutter_timer_tutorial/background.dart.md ':include')

### Juntando tudo

Nosso `main.dart` finalizado deve se parecer com:

[main.dart](../_snippets/flutter_timer_tutorial/main2.dart.md ':include')

Isso é tudo! Neste ponto, temos um aplicativo de cronômetro bastante sólido que reconstrói com eficiência apenas os widgets que precisam ser reconstruídos.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
