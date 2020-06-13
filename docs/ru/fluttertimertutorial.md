# Flutter Таймер

![начинающий](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы расскажем, как создать приложение таймера с помощью библиотеки `bloc`. Готовое приложение должно выглядеть так:

![демо](../assets/gifs/flutter_timer.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_timer_tutorial/pubspec.yaml.md ':include')

Затем запустить `flutter packages get`, чтобы установить все зависимости.

?> **Примечание:** В этом приложении мы будем использовать [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable) и [wave](https://pub.dev/packages/wave) пакеты.

## Тикер

> `Ticker` будет нашим источником данных для приложения таймера. Он создаст поток тиков, на которые мы можем подписаться и на которые будем реагировать.

Начнем с создания `ticker.dart`.

[ticker.dart](../_snippets/flutter_timer_tutorial/ticker.dart.md ':include')

Все, что делает наш класс `Ticker` - предоставляет функцию tick, которая принимает желаемое количество тиков (секунд) и возвращает поток, который генерирует оставшиеся секунды каждую секунду.

Далее нам нужно создать наш `TimerBloc`, который будет использовать `Ticker`.

## Bloc таймера

### Состояние

Мы начнем с определения `TimerStates`, в котором может находиться наш `TimerBloc`.

Наше состояние `TimerBloc` может быть одним из следующих:

- TimerInitial — готов начать обратный отсчет с указанной продолжительностью.
- TimerRunInProgress — отсчитывает в обратном порядке указанную продолжительность.
- TimerRunPause — остановлен на одном из значений оставшейся продолжительности.
- TimerRunComplete — завершен с оставшейся продолжительностью 0.

Каждое из этих состояний будет влиять на то, что видит пользователь. Например:

- если состояние `TimerInitial`, пользователь сможет запустить таймер.
- если состояние `TimerRunInProgress` пользователь сможет приостановить или сбросить таймер, а также увидеть оставшуюся продолжительность.
- если состояние `TimerRunPause`, пользователь может возобновить или сбросить таймер.
- если состояние `TimerRunComplete`, пользователь может сбросить таймер.

Чтобы держать все наши файлы блоков вместе, давайте создадим каталог `bloc` c файлом `bloc/timer_state.dart`.

?> **Совет:** Вы можете использовать [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) расширения для автоматического создания следующих файлов блока.

[timer_state.dart](../_snippets/flutter_timer_tutorial/timer_state.dart.md ':include')

Обратите внимание, что все `TimerStates` расширяют абстрактный базовый класс `TimerState`, который имеет свойство `duration`. Это потому, что независимо от того, в каком состоянии находится наш `TimerBloc`, мы хотим знать сколько времени осталось.

Далее, давайте определим и реализуем `TimerEvents`, который будет обрабатывать наш `TimerBloc`.

### События

Наш `TimerBloc` должен знать, как обрабатывать следующие события:

- TimerStarted — сообщает TimerBloc, что таймер должен быть запущен.
- TimerPaused — сообщает TimerBloc, что таймер должен быть приостановлен.
- TimerResumed — сообщает TimerBloc, что работа таймера должна быть возобновлена.
- TimerReset — сообщает TimerBloc, что таймер должен быть сброшен в исходное состояние.
- TimerTicked — информирует TimerBloc о том, что произошел тик и что ему необходимо соответствующим образом обновить свое состояние.

Если вы не использовали [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), создадим файл `bloc/timer_event.dart` и реализуем эти события.

[timer_event.dart](../_snippets/flutter_timer_tutorial/timer_event.dart.md ':include')

Далее давайте реализуем `TimerBloc`!

### Блок

Если вы этого еще не сделали, создайте `bloc/timer_bloc.dart` и создайте пустой `TimerBloc`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_empty.dart.md ':include')

Первое, что нам нужно сделать, это определить `initialState` нашего `TimerBloc`. В этом случае мы хотим, чтобы `TimerBloc` запускался в состоянии `TimerInitial` с заданной продолжительностью 1 минута (60 секунд).

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

Далее нам нужно определить зависимость от нашего `Ticker`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

Мы также определяем `StreamSubscription` для нашего `Ticker`, к которому мы скоро перейдем.

На данный момент все, что осталось сделать, это реализовать `mapEventToState`. Для улучшения читаемости мне нравится разбивать каждый обработчик событий на его собственную вспомогательную функцию. Начнем с события `TimerStarted`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

Если `TimerBloc` получает событие `TimerStarted`, он переводит состояние в `TimerRunInProgress` с первоначальной продолжительностью. Кроме того, если уже была открытая `_tickerSubscription`, нам нужно отменить ее, чтобы освободить память. Нам также нужно переопределить метод `close` нашего `TimerBloc`, чтобы мы могли отменить `_tickerSubscription` когда `TimerBloc` закрыт. Наконец, мы слушаем поток `_ticker.tick` и на каждом тике мы добавляем событие `TimerTicked` с оставшейся продолжительностью.

Теперь давайте реализуем обработчик событий `TimerTicked`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

Каждый раз, когда получено событие `TimerTicked`, если длительность тика больше 0, нам нужно выставить обновленное состояние `TimerRunInProgress` с новой продолжительностью. В противном случае, если длительность тика равна 0, наш таймер закончился и нам нужно перейти в состояние `TimerRunComplete`.

Теперь давайте реализуем обработчик событий `TimerPaused`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

В `_mapPauseToState`, если `state` нашего `TimerBloc` равно `TimerRunInProgress`, тогда мы можем приостановить `_tickerSubscription` и выставить состояние `TimerRunPause` с текущей длительностью таймера.

Далее, давайте реализуем обработчик событий `TimerResumed`, чтобы мы могли отключать таймер.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

Обработчик события `TimerResumed` очень похож на обработчик события `TimerPaused`. Если `TimerBloc` имеет `state` `TimerRunPause` и он получает событие `TimerResumed`, то он возобновляет `_tickerSubscription` и выставляет состояние `TimerRunInProgress` с текущей продолжительностью.

Наконец, нам нужно реализовать обработчик события `TimerReset`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc.dart.md ':include')

Если `TimerBloc` получает событие `TimerReset`, ему необходимо отменить текущую `_tickerSubscription`, чтобы он не уведомлялся о каких-либо дополнительных тиках и выставить состояние `TimerInitial` с первоначальной продолжительностью.

Если вы не использовали [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) расширения, обязательно создайте `bloc/bloc.dart` для того, чтобы экспортировать все файлы блока и для удобства использовать один импорт.

[bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_barrel.dart.md ':include')

Это все, что есть в `TimerBloc`. Теперь осталось только реализовать пользовательский интерфейс для нашего приложения `Timer`.

## UI приложения

### MyApp

Мы можем начать с удаления содержимого файла `main.dart` и создания нашего виджета `MyApp`, который будет корнем нашего приложения.

[main.dart](../_snippets/flutter_timer_tutorial/main1.dart.md ':include')

`MyApp` - это `StatelessWidget`, который будет управлять инициализацией и закрытием экземпляра `TimerBloc`. Кроме того, он использует виджет `BlocProvider`, чтобы сделать наш экземпляр `TimerBloc` доступным для виджетов в нашем поддереве.

Далее нам нужно реализовать наш виджет `Timer`.

### Таймер

Наш виджет `Таймер` будет отвечать за отображение оставшегося времени вместе с соответствующими кнопками, которые позволят пользователям запускать, приостанавливать и сбрасывать таймер.

[timer.dart](../_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

Пока что мы просто используем `BlocProvider` для доступа к экземпляру нашего `TimerBloc` и используем виджет `BlocBuilder` для перестройки пользовательского интерфейса каждый раз, когда мы получаем новый `TimerState`.

Далее мы собираемся реализовать наш виджет `Actions`, который будет иметь соответствующие действия (запуск, пауза и сброс).

### Действия

[actions.dart](../_snippets/flutter_timer_tutorial/actions.dart.md ':include')

Виджет `Actions` - это просто еще один `StatelessWidget`, который использует `BlocProvider` для доступа к экземпляру `TimerBloc`, а затем возвращает различные `FloatingActionButtons` в зависимости от текущего состояния `TimerBloc`. Каждый из `FloatingActionButtons` добавляет событие в свой обратный вызов `onPressed`, чтобы уведомить `TimerBloc`.

Теперь нам нужно подключить `Actions` к нашему виджету `Timer`.

[timer.dart](../_snippets/flutter_timer_tutorial/timer2.dart.md ':include')

Мы добавили еще один `BlocBuilder`, который будет отображать виджет `Actions`, однако на этот раз мы используем недавно представленную функцию [flutter_bloc](https://pub.dev/packages/flutter_bloc), чтобы контролировать, как часто перестраивается виджет `Actions` (представлено в `v0.15.0`).

Если вам нужен детальный контроль над тем, когда вызывается функция `builder`, вы можете предоставить необязательное условие для `BlocBuilder`. Условие принимает предыдущее и текущее состояние блока и возвращает логическое значение. Если `condition` возвращает `true`, `builder` будет вызван со `state` и виджет будет перестроен. Если `condition` возвращает `false`, `builder` не будет вызван со `state` и перестройка не произойдет.

В данном случае мы не хотим, чтобы виджет `Actions` перестраивался на каждом тике, потому что это было бы неэффективно. Вместо этого мы хотим, чтобы `Actions` перестраивался только в том случае, если изменяется `runtimeType` `TimerState` (TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, ...).

В результате, если мы случайно раскрасим виджеты при каждой перестройке, это будет выглядеть так:

![BlocBuilder condition demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Примечание:** Несмотря на то, что виджет `Text` перестраивается на каждом тике, мы перестраиваем `Actions` только в том случае, если их нужно перестроить.

Наконец, нам нужно добавить очень крутой фон волны, используя пакет [wave](https://pub.dev/packages/wave).

### Фон волны

[background.dart](../_snippets/flutter_timer_tutorial/background.dart.md ':include')

### Собираем все вместе

наш финальный `main.dart` должен выглядеть приблизительно так:

[main.dart](../_snippets/flutter_timer_tutorial/main2.dart.md ':include')

Вот и все, что нужно сделать! На данный момент у нас есть довольно солидное приложение таймера, которое эффективно перестраивает только те виджеты, для которых это действительно нужно.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
