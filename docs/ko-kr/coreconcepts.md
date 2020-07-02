# 주요 개념

?> [bloc](https://pub.dev/packages/bloc)을 사용하기 전에 다음 내용을 잘 읽고 이해하기 바랍니다.

Bloc을 어떻게 사용하는지 이해하기 위해서는 알아야 하는 몇가지 개념이 있습니다.

다음 섹션에서 각 개념들을 자세히 이야기해보고 실제 어플리케이션인 계수기  만들고 있기 때문에, state는 간단합니다.앱에 적용시켜보도록 하겠습니다.

## Events

> Event는 Bloc에 입력값으로 보통 버튼 클릭이나 페이지 로드 등 lifecycle event와 같은 유저와의 상호 작용에서 생성됩니다.

앱을 만들 때 먼저 유저가 우리 앱과 어떻게 상호작용 할지 정의해야합니다. 계수기  만들고 있기 때문에, state는 간단합니다. 앱에는 숫자를 늘리거나 줄일 수 있는 증가, 감소 버튼이 있습니다.

만일 유저가 버튼을 클릭하면, 유저 입력에 반응하게 하기 위해 누군가는 우리 앱의 "뇌"에 이 사실을 알려줘야 합니다; 여기가 event가 역할을 하는 곳입니다.

우리는 앱의 "뇌"에 숫자를 늘리고, 줄이는 것을 알릴 수 있어야 합니다. 이를 위해 우리는 두 event를 다음과 같이 정의합니다.

[counter_event.dart](../_snippets/core_concepts/counter_event.dart.md ':include')

이 상황에서 event를 `enum`을 이용해서 나타냈지만, bloc에 정보를 전달해야 한다거나 더욱 복잡한 상황에서는 `class`를 사용해야할 수도 있습니다.

이렇게 event를 처음으로 정의해보았습니다! 이 시점에서 우리는 아직 Bloc을 사용하지 않았고 아무런 마법도 일어나지 않습니다; 이 코드는 Plain Dart 코드입니다.

## States

> State는 Bloc의 출력값으로 어플리케이션의 상태의 일부를 나타냅니다. State는 UI 컴포넌트에게 현재 state를 알려주어 UI 컴포넌트의 일부분을 다시 그리게 하기도 합니다.

여기까지, 우리 앱이 반응할 두개의 event를 정의했습니다: `CounterEvent.increment` 와 `CounterEvent.decrement`.

이제 우리는 어떻게 우리 어플리케이션의 state를 나타낼지 정의해야 합니다.

우리는 계수기를 만들고 있기 때문에, state는 매우 간단합니다: 계수기의 현재 숫자을 나타내는 정수면 됩니다.

앞으로 state의 복잡한 예시를 보게 되겠지만, 우리 어플리케이션의 state를 표현하는데 이 정도의 매우 단순한 형태면 충분합니다.

## Transitions

> 하나의 state에서 다른 state로의 변화를 Transition이라고 합니다. Transition은 현재 state, event, 그리고 다음 state로 구성되어 있습니다.

유저가 우리 계수기 앱을 사용하면서, 현재 계수기의 state를 업데이트하는 `Increment`, `Decrement` event를 발생시킬 것입니다.

For example, if a user opened our app and tapped the increment button once we would see the following `Transition`.

예를 들어, 유저가 계수기 앱을 열고 증가 버튼을 누르면, 다음과 같은 `Transition`을 확인할 수 있습니다.

[counter_increment_transition.json](../_snippets/core_concepts/counter_increment_transition.json.md ':include')

모든 state 변화는 기록되기 때문에, 매우 쉽게 계측하고, 모든 사용자 상호 작용 및 상태 변화를 한 곳에서 추적 할 수 있습니다. 뿐만 아니라, 이는 time-travel 디버깅과 같은 기능을 가능하게 합니다.

## Streams

?> Stream에 대한 자세한 정보를 얻고 싶다면 공식 [Dart 문서](https://dart.dev/tutorials/language/streams)를 참고하세요.

> Stream은 일련의 asynchronous data입니다.

Bloc을 사용하기 위해서는, `Stream`과 이것의 동작 원리를 제대로 이해하는 것이 중요합니다.

> 만일 `Stream`이 아직 어색하다면 물이 흐르는 파이프를 생각해봅시다. 파이프가 `Stream`
에 해당하고 물은 asynchronous data입니다.

우리는 Dart에서 `async*` 함수를 써서 `Stream`을 생성할 수 있습니다.

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

함수를 `async*`로 표시함으로써 `yield` 키워드를 사용할 수 있고 data의 `Stream`을 반환할 수 있습니다. 위의 예시에서, 함수는 `max`까지의 정수의 `Stream`을 반환합니다.

`async*` 함수에서 `yield`할 때마다, `Stream`을 통해 data의 일부분을 푸쉬하게 됩니다.

우리는 `Stream`을 다양한 방법으로 받을 수 있습니다. 만일 `Stream`의 정수들의 합을 반환하는 함수를 작성한다면, 다음과 같이 할 수 있습니다.

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

위의 함수를 `async`로 표기함으로써, 우리는 `await` 키워드를 사용하여 정수들의 `Future`을 반환할 수 있습니다. 위의 예시에서, 우리는 stream의 각각의 값을 기다리고 있다가 Stream의 모든 정수의 합을 반환합니다.

다음과 한 곳에 모을 수 있습니다:

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

## Blocs

> Bloc(Business Logic Component)은 들어오는 `Events` `Stream`을 나가게 될 `States` `Stream`으로 변환하는 컴포넌트입니다.
> 모든 Bloc은 bloc 핵심 패키지의 일부인 `Bloc` 클래스를 확장해야 합니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_class.dart.md ':include')

위의 함수에서, `CounterBloc`은 `CounterEvent`를 `ints`로 변환하는 Bloc으로 선언했습니다.

> 모든 Bloc은 event를 받기 전 초기 state를 정의해야 합니다.

이 경우에, 우리의 계수기 초기 값을 `0`으로 정의하겠습니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_initial_state.dart.md ':include')

> Every Bloc must implement a function called `mapEventToState`. The function takes the incoming `event` as an argument and must return a `Stream` of new `states` which is consumed by the presentation layer. We can access the current bloc state at any time using the `state` property.
> 모든 Bloc에는 반드시 `mapEventToState` 함수를 구현해야 합니다. 이 함수는 들어오는 `event`를 인자로 받아 presentation 층에서 쓰는 새로운 `state`의 `stream`을 반환하게 됩니다. 우리는 `state` 속성을 이용해서 현재 bloc의 state를 아무 때나 접근할 수 있습니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_map_event_to_state.dart.md ':include')

드디어, 제대로 동작하는 `CounterBloc`이 하나 만들어졌습니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

!> Bloc은 동일한 state는 무시합니다. 만일 Bloc이 `state == nextState`인 `State nextState`를 보내면, transation은 발생하지 않고 `Stream<State>`에 아무런 변화도 일어나지 않습니다.

이쯤에 다음과 같은 질문을 하고 계실지 모르겠습니다. _"어떻게 Bloc에게 event를 알리지?"_.

> 모든 Bloc은 `add` 함수를 가지고 있습니다. `Add`는 `event`를 받아서 `mapEventToState`를 동작하게 합니다. 예를 들어, presentation 층이나 Bloc 내부에서 `Add`를 호출하고 Bloc에게 새로운 `event`를 알립니다.

다음과 같이 0부터 3까지 수를 세는 간단한 어플리케이션을 만들수 있습니다.

[main.dart](../_snippets/core_concepts/counter_bloc_main.dart.md ':include')

!> 기본적으로, event는 추가된 순서대로 처리되게 됩니다. 하나의 event는 `mapEventToState` 실행이 완료되면 완전히 처리됐다고 여겨집니다.

위의 코드가 진행되면 다음과 같은 Transition이 생성되게 됩니다.

[counter_bloc_transitions.json](../_snippets/core_concepts/counter_bloc_transitions.json.md ':include')

불행히도, 현재 state에서 우리는 `onTransition`을 override하지 않는 한 이런 transition을 볼 수 없습니다.

> `onTransition`은 모든 local Bloc `Transition`을 처리할 수 있는 함수입니다. `onTransition`은 Bloc의 `state`가 업데이트 되기 직전에 호출됩니다.

?> **팁**: `onTransition`는 bloc에 특성화된 로깅과 분석을 하기에 매우 용이합니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

이제 우리는 `onTransition`을 override했기 때문에, `Transition`이 발생함에 따라 무엇이든 할 수 있습니다.

`Transitions`을 bloc level에서 다뤘듯이, `Exceptions`도 다룰 수 있습니다.

> `onError`은 local Bloc `Exception`을 핸들링하기 위해 overide할 수 있는 함수입니다. 기본적으로 모든 exception은 무시되고 `Bloc`의 기능에는 영향을 미치지 않습니다.

?> **노트**: 만일 state stream이 `StackTrace`가 없는 에러를 받으면 stackTrace 인자는 `null`일 수 있습니다.
?> **팁**: `onError`은 bloc에 따른 에러 핸들링하기에 매우 용이합니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

이제 우리는 `onError`을 override했기 때문에, `Exception`이 발생함에 따라 무엇이든 할 수 있습니다.

## BlocDelegat

Bloc을 사용하는 또 하나의 장점으로 한 곳에서 모든 `Transition`에 대한 access를 가지게 됩니다. 이 어플리케이션에서는 Bloc이 하나 뿐이지만, 좀 더 큰 어플리케이션에서는 어플리케이션의 state를 관리하는 Bloc이 여러개인 경우가 빈번합니다.

만일 모든 `Transition`에 대해 어떠한 액션을 할 수 있기를 원한다면, 우리는 간단히 `BlocObserver`를 생성하면 됩니다.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer.dart.md ':include')

?> **노트**: `BlocObserver`를 extend하고 `onTransition`함수를 override하기만 하면 됩니다.

Bloc에게 우리가 만든 `SimpleBlocObserver`를 사용하게 하기 위해서는, `main` 함수를 조금 바꾸면 됩니다.

[main.dart](../_snippets/core_concepts/simple_bloc_observer_main.dart.md ':include')

만일 모든 추가되는 `Event`에 직접 반응하고 싶다면, `SimpleBlocObserver`에서 `onEvent` 함수를 override하면 됩니다.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

만일 Bloc에서 발생하는 모든 `Exception`에 직접 반응하고 싶다면, `SimpleBlocObserver`에서 `onError` 함수를 override하면 됩니다.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_complete.dart.md ':include')