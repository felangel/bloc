# Core Concepts (package:bloc)

?> [package:bloc](https://pub.dev/packages/bloc)을 사용하기 전에 다음 섹션들을 자세하게 살펴보세요.

Bloc package를 사용하는 방법을 이해하는 데 중요한 몇 가지 핵심 개념이 있습니다.
다음 섹션에서, 그 개념을 자세히 살펴보고 counter app에 어떻게 적용되는지 알아봅니다.

## Streams

?> `Streams`이 무엇인지 자세하게 알고 싶다면 [Dart Documentation](https://dart.dev/tutorials/language/streams)을 참고하세요.

> Stream은 비동기 데이터들의 시퀀스 입니다.

Bloc library를 사용하기 위해서, `Streams`이 어떻게 작동하는지 이해하는 것이 매우 중요합니다.

> `Streams`이 무엇인지 잘 모르겠다면, 물이 흐르는 파이프를 생각해보세요. `Stream`은 파이프이고, 비동기 데이터들이 물입니다.

Dart에서 `async*`(async generator) 함수를 사용하면 `Stream`을 만들 수 있습니다.

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

함수를 `async*`로 마킹하면, `yield` 키워드를 사용해서 데이터의 `Stream`을 반환할 수 있습니다. 위의 코드에서, 정수형 파라미터인 `max`값까지 정수들의 `Stream`을 반환합니다.

`async*` 함수에서 `yield`를 할 때마다, `Stream`으로 데이터의 조각을 푸시합니다.

위의 `Stream`은 다양한 방법으로 사용이 가능합니다. 만약 정수들의 `Stream`의 합을 반환하는 함수를 작성한다면, 다음과 같은 코드가 가능합니다:

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

위의 함수를 `async`로 마킹함으로써 `await` 키워드를 사용할 수 있고, 정수들의 `Future` 값을 반환합니다. 위의 예제에서, 스트림의 각 값들을 기다리고 모든 정수들의 합을 반환합니다.

다음과 같이 코드를 정리 할 수 있습니다:

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

여기까지 우리는 `Streams`이 Dart에서 어떻게 작동하는지 알아봤습니다. 이제 bloc package의 핵심 구성요소인 `Cubit`에 대해 배워볼까요?

## Cubit

> `Cubit`은 `BlocBase`를 확장한 클래스로 어떤 타입의 상태라도 관리할 수 있도록 확장할 수 있습니다.

![Cubit Architecture](../assets/cubit_architecture_full.png)

`Cubit`은 상태의 변화를 트리거하는 함수를 가지고 있습니다.

> 상태는 `Cubit`의 출력이고 애플리케이션의 상태의 일부를 나타냅니다. UI 구성요소들은 상태에 대한 정보를 받고, 현재 상태를 기반으로 스스로를 다시 그립니다.

> **Note**: `Cubit`의 기원에 대해 자세히 알고 싶다면 [the following issue](https://github.com/felangel/cubit/issues/69)을 참고하세요.

### Cubit 구현하기

`CounterCubit`을 다음과 같이 구현할 수 있습니다:

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit.dart.md ':include')

`Cubit`을 생성 할 때, `Cubit`이 관리할 상태의 타입을 정의해야합니다. 위의 `CounterCubit`의 경우에, 상태는 `int`로 표현되지만 더 복잡한 경우에는 primitive 타입 대신에 `class`를 사용해야 할 수 있습니다.

두 번째로 `Cubit`을 생성할 때 해야 하는 것은 초기 상태를 정하는 것입니다. 이 작업은 초깃값과 함께 `super`를 호출하면서 이루어집니다. 위의 코드에서, 우리는 내부적으로 초깃값을 `0`으로 세팅했지만 외부의 값을 받을 수 있게 하여 좀 더 유연한 `Cubit`을 만들 수 있습니다:

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_initial_state.dart.md ':include')

이것은 `CounterCubit` 인스턴스를 다음과 같이 다른 초깃값들로 초기화할 수 있게 해줍니다:

[main.dart](../_snippets/core_concepts/counter_cubit_instantiation.dart.md ':include')

### 상태 변화

> 각 `Cubit`은 `emit`을 사용해 새로운 상태 값을 만들 수 있습니다.

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_increment.dart.md ':include')

위의 코드에서, `CounterCubit`는 외부에서 `CounterCubit`에게 상태값의 증가를 알릴 수 있게 하는 `increment`라는 public 메소드를 가지고 있습니다. `increment`가 호출될 때, `state` getter를 이용해 `Cubit`의 현재 상태에 접근할 수 있고, 현재 상태에 1을 더함으로써 새로운 상태를 `emit` 합니다.

!> `emit` 메서드는 보호되고, 오직 `Cubit` 안에서만 사용이 가능합니다.

### Cubit 사용하기

이제 우리가 구현한 `CounterCubit`을 가져와서 사용할 수 있습니다!

#### 기본 사용법

[main.dart](../_snippets/core_concepts/counter_cubit_basic_usage.dart.md ':include')

위의 코드는 `CounterCubit`의 인스턴스를 생성하며 시작합니다. 그다음 아직 새로운 상태가 emit 되지 않았기 때문에, 초깃값인 cubit의 현재 상태를 출력합니다. 다음으로, 상태 변화를 트리거 하기 위해 `increment` 함수를 호출합니다. 마지막으로, `0`에서 `1`로 바뀐 `Cubit`의 상태를 다시 출력하고 내부의 상태 스트림을 닫기 위해 `Cubit`에 `close`를 호출합니다.

#### Stream 사용법

`Cubit`은 실시간 상태 업데이트를 수신할 수 있게 해주는 `Stream`을 가지고 있습니다.

[main.dart](../_snippets/core_concepts/counter_cubit_stream_usage.dart.md ':include')

위의 코드에서, `CounterCubit`을 subscribe 하고 각 상태 변화를 출력합니다. 그다음 새로운 상태를 emit 하는 `increment` 함수를 호출합니다. 마지막으로, 더 이상 업데이트 수신을 원하지 않을 때 `subscription`을 `cancel`하고 `Cubit`을 close 합니다.

?> **Note**: 이 예제의 `await Future.delayed(Duration.zero)`는 subscription을 바로 cancel 하는 것을 막기 위해 추가되었습니다.

!> `Cubit`에 대해 `listen`을 호출했을 때 호출 이후에 발생하는 상태 변화만 수신이 가능합니다.

### Cubit 관찰하기

> `Cubit`이 새로운 상태를 emit 할 때, `Change`가 발생합니다. `onChange`를 재정의함으로써, `Cubit`의 모든 변화를 관찰할 수 있습니다.

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_on_change.dart.md ':include')

그 다음 `Cubit`과 상호작용이 가능하고, 콘솔로 모든 변화의 출력을 관찰합니다.

[main.dart](../_snippets/core_concepts/counter_cubit_on_change_usage.dart.md ':include')

위 코드의 결과는 다음과 같습니다:

[script](../_snippets/core_concepts/counter_cubit_on_change_output.sh.md ':include')

?> **Note**: `Change`는 `Cubit`의 상태 업데이트가 이루어진 후 발생합니다. `Change`는 `currentState`와 `nextState`로 구성됩니다.

#### BlocObserver

Bloc library에서 모든 `Changes`를 한 곳에서 접근하는 것이 가능합니다. 비록, 위의 코드에서 우리는 하나의 `Cubit`을 가지지만, 더 큰 앱들은 보통 앱 상태의 다른 부분들을 관리하는 많은 `Cubits`을 가집니다.

만약 모든 `Changes`에 응답하고 싶다면, 커스텀 `BlocObserver`을 구현하면 됩니다.

[simple_bloc_observer_on_change.dart](../_snippets/core_concepts/simple_bloc_observer_on_change.dart.md ':include')

?> **Note**: 그저 `BlocObserver`를 확장하고 `onChange` 메서드를 재정의 하면 됩니다.

위의 `SimpleBlocObserver`를 사용하고 싶다면, `main` 함수를 수정하면 됩니다.

[main.dart](../_snippets/core_concepts/simple_bloc_observer_on_change_usage.dart.md ':include')

위 코드의 결과는 다음과 같습니다:

[script](../_snippets/core_concepts/counter_cubit_on_change_usage_output.sh.md ':include')

?> **Note**: 내부의 `onChange` 재정의가 가장 처음에 호출되고 이어서 `BlocObserver`의 `onChange`가 호출됩니다.

?> 💡 **Tip**: `BlocObserver`에서 `Change` 뿐만 아니라 `Cubit` 인스턴스에 대한 접근도 가능합니다

### 에러 핸들링

> 모든 `Cubit`은 에러 발생을 알려주는 메소드인 `addError`를 가지고 있습니다.

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_on_error.dart.md ':include')

?> **Note**: 특정 `Cubit`에 대해 모든 에러를 처리하고 싶다면, `Cubit` 내부에서 `onError`를 재정의하면 됩니다.

전역적으로 발생하는 모든 에러들을 다루고 싶다면, `BlocObserver`의 `onError`를 재정의하세요.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_error.dart.md ':include')

동일한 프로그램을 다시 실행하면 다음과 같은 출력을 얻습니다:

[script](../_snippets/core_concepts/counter_cubit_on_error_output.sh.md ':include')

?> **Note**: `onChange`에서 그랬던 것처럼, 내부의 `onError`가 글로벌 `BlocObserver` 재정의보다 먼저 호출됩니다.

## Bloc

> `Bloc`는 `state` 변화를 트리거하기 위해 함수가 아닌, `events`에 의존하는 고급 클래스 입니다. `Bloc`는 `BlocBase`를 확장하고 그것은 `Cubit`과 비슷한 public API를 가진다는 것을 의미합니다. 그러나, `Blocs`는 `function`을 호출하고 새로운 `state`를 emit 하기 보다, `events`를 수신하고 수신된 `events`를 출력될 `states`로 변환합니다.

![Bloc Architecture](../assets/bloc_architecture_full.png)

### Bloc 생성하기

`Bloc`를 생성하는 것은 관리할 상태를 정의하는 것을 제외하면 `Cubit`을 생성하는 것과 비슷합니다. `Bloc`가 처리할 이벤트도 반드시 정의해야 합니다.

> 이벤트는 Bloc의 입력입니다. 일반적으로 페이지 로드와 같은 생명주기 이벤트나 버튼 누르기와 같은 사용자 상호 작용에 따라 추가됩니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

`CounterCubit`을 정의할 때 했던 것처럼, `super`를 사용하여 superclass로 초기 상태 값을 설정해야 합니다.

### 상태 변화

`Bloc`는 `Cubit`의 함수와 다르게 `on<Event> `API를 사용하여 이벤트 핸들러를 등록하도록 합니다. 이벤트 핸들러는 입력으로 들어온 이벤트들을 0개 이상의 출력 상태로 변환합니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_event_handler.dart.md ':include')

?> 💡 **Tip**: `EventHandler`는 `Emitter` 뿐만 아니라 추가된 이벤트에도 접근이 가능합니다. `Emitter`는 수신된 이벤트에 반응하여 0개 이상의 상태들을 emit 할 때 사용됩니다.

그런 다음 우리는`EventHandler`를 업데이트하여 `CounterIncrementPressed` 이벤트를 처리할 수 있습니다:

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_increment.dart.md ':include')

위의 코드에서, 모든 `CounterIncrementPressed` 이벤트들을 관리하기 위해 `EventHandler`을 등록합니다. 수신되는 모든 `CounterIncrementPressed` 이벤트에서 `state` getter와 `emit(state + 1)`를 통해 bloc의 현재 상태에 접근이 가능합니다.

?> **Note**: `Bloc`가 `BlocBase`를 확장하기 때문에, `Cubit` 처럼 `state` getter를 사용하여 언제라도 bloc의 헌재 상태에 접근할 수 있습니다.

!> Blocs는 절대 직접적으로 새로운 상태를 `emit` 해서는 안 됩니다. 대신 모든 상태 변경은 `EventHandler` 내의 수신 이벤트에 대한 응답으로 출력되어야 합니다.

!> Blocs과 Cubits 모두 중복 상태는 무시합니다. 만약 `state == nextState `일 때, `State nextState`을 emit 해도, 아무런 상태 변화가 발생하지 않습니다.

### Bloc 사용하기

이 시점에서, 우리는 `CounterBloc`의 인스턴스를 생성해서 사용할 수 있습니다!

#### 기본 사용법

[main.dart](../_snippets/core_concepts/counter_bloc_usage.dart.md ':include')

위의 코드는, `CounterBloc`의 인스턴스를 생성하며 시작합니다. 그 다음 초기 상태인 (아직 아무런 emit을 하지 않았기 때문에) `Bloc`의 현재 상태를 출력합니다. 다음으로, 상태 변화를 트리거하기 위해 `CounterIncrementPressed` 이벤트를 추가합니다. 마지막으로, `0`에서 `1`로 변한 `Bloc`의 상태를 출력하고 내부 상태 스트림을 닫기 위해 `Bloc`에 `close`를 호출합니다.

?> **Note**: `await Future.delayed(Duration.zero)`은 다음 이벤트 루프 반복을 기다리는 것을 보장하기 위해 추가되었습니다 (`EventHandler`가 다음 이벤트를 처리하도록 합니다).

#### Stream 사용법

`Cubit`처럼, `Bloc`도 `Stream`의 특정한 타입이고 이은 `Bloc`을 subscribe하여 상태를 실시간으로 업데이트할 수 있다는 것을 의미합니다.

[main.dart](../_snippets/core_concepts/counter_bloc_stream_usage.dart.md ':include')

위의 코드에서, `CounterBloc`을 subscribe하고 각 상태 변화에서 출력을 호출합니다. 그런 다음 `on<CounterIncrementPressed>` EventHandler 를 트리거하는 `CounterIncrementPressed` 이벤트를 추가하고, 새로운 상태를 emit 합니다. 마지막으로, 더 이상 업데이트 수신이 필요 없어졌을 때 subscription에 대해 `cancel` 를 호출하고 `Bloc`를 닫습니다.

?> **Note**: `await Future.delayed(Duration.zero)`는 subscription이 바로 취소되는 것을 피하기 위해 추가되었습니다.

### Bloc 관찰하기

`Bloc`가 `BlocBase`를 확장하기 때문에, `Bloc`의 모든 상태 변화는 `onChange`로 관찰할 수 있습니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_change.dart.md ':include')

`main.dart`를 다음과 같이 수정할 수 있습니다:

[main.dart](../_snippets/core_concepts/counter_bloc_on_change_usage.dart.md ':include')

위의 코드를 실행하면, 다음과 같은 출력이 나옵니다:

[script](../_snippets/core_concepts/counter_bloc_on_change_output.sh.md ':include')

`Bloc`와 `Cubit`의 가장 큰 차이점은 `Bloc`는 이벤트 중심이기 때문에, 무엇이 상태의 변화를 트리거 했는지에 대한 정보를 얻을 수 있습니다.

이런 작업은 `onTransition`을 재정의함으로써 구현할 수 있습니다.

> 한 상태에서 다른 상태로 변하는 것을 `Transition`이라 부릅니다. `Transition`은 현재 상태, 이벤트, 그리고 다음 상태로 구성됩니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

여기에서 다시 동일한 `main.dart`를 실행하면, 다음과 같은 출력을 얻습니다:

[script](../_snippets/core_concepts/counter_bloc_on_transition_output.sh.md ':include')

?> **Note**: `onTransition`은 `onChange` 앞에 호출되며 `currentState`에서 `nextState`로의 변화를 어떤 이벤트가 트리거 했는지 포함합니다.

#### BlocObserver

앞에서 그랬던 것처럼, 코드의 한 장소에서 모든 트랜지션을 관찰하고 싶다면 커스텀 `BlocObserver`의 `onTransition`을 재정의하면 됩니다.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_transition.dart.md ':include')

`SimpleBlocObserver`를 이전에 했던 것처럼 초기화합니다.

[main.dart](../_snippets/core_concepts/simple_bloc_observer_on_transition_usage.dart.md ':include')

이제 위의 코드를 실행하면, 다음과 같은 결과가 출력됩니다:

[script](../_snippets/core_concepts/simple_bloc_observer_on_transition_output.sh.md ':include')

?> **Note**: `onTransition`이 (local 이후에 global) `onChange` 보다 먼저 출력됩니다.

`Bloc` 인스턴스의 또다른 특징은 `onEvent`를 재정의 할 수 있다는 것입니다. `onEvent`는 `Bloc`에 새로운 이벤트가 추가될 때마다 호출됩니다. `onChange`와 `onTransition` 처럼 `onEvent`도 전역적으로, 지역적으로 모두 재정의 될 수 있습니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_event.dart.md ':include')

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

이전과 동일한 `main.dart`를 실행하면 다음과 같은 결과를 출력합니다:

[script](../_snippets/core_concepts/simple_bloc_observer_on_event_output.sh.md ':include')

?> **Note**: `onEvent`는 이벤트가 추가되자마자 호출됩니다. local `onEvent`는 `BlocObserver`의 global `onEvent`보다 먼저 호출됩니다.

### 에러 핸들링

`Cubit`처럼, 각 `Bloc`은 `addError`와 `onError` 메서드를 가지고 있습니다. `Bloc`의 내부 어디에서든 `addError`를 호출함으로써 에러가 발생했다는 것을 나타낼 수 있습니다. 마찬가지로 `Cubit`처럼, `onError`를 재정의함므로써 모든 에러들에 반응할 수 있습니다.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

여기에서 동일한 `main.dart`를 다시 실행하면, 다음과 같은 에러가 보고 됩니다:

[script](../_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **Note**: local `onError`가 먼저 호출된 후 global `BlocObserver`에서 `onError`가 호출됩니다.

?> **Note**: `onError`와 `onChange`는 `Bloc`과 `Cubit` 인스턴스에서 정확히 같은 방법으로 작동합니다.

!> `EventHandler`에서 발생한 처리되지 않은 예외들도 `onError`로 보고 됩니다.

## Cubit vs. Bloc

여기까지 우리는 `Cubit`과 `Bloc` 클래스의 기본을 배웠습니다. 그렇다면 언제 `Cubit`을 사용하고, `Bloc`을 사용해야 하는지 궁금하지 않나요?

### Cubit의 장점

#### Simplicity

`Cubit`의 가장 큰 장점은 간단하다는 것입니다. `Cubit`을 생성할 때, 상태와 상태를 변경하기 위한 함수만 정의하면 됩니다. 하지만, `Bloc`를 생성할 때는 상태, 이벤트, `EventHandler`까지 구현해야 합니다. 이러한 점이 `Cubit`을 더 이해하기 쉽고 짧은 코드로 작성이 가능하게 합니다. 

이제 두 개의 counter 구현에 대해 살펴봅시다:

##### CounterCubit

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_full.dart.md ':include')

`Cubit`의 구현이 더 간단하고 이벤트를 분리해서 정의하기보다, 함수가 이벤트처럼 행동합니다. 게다가, `Cubit`을 사용할 때, 상태 변화를 트리거 하고 싶다면, 어디서든 `emit`을 호출하면 됩니다.

### Bloc의 장점

#### Traceability

`Bloc`의 가장 큰 장점 중 하나는 상태 변화의 시퀀스뿐만 아니라 무엇이 변화를 트리거 했는지 정확하게 알 수 있다는 것입니다. 앱의 기능적으로 매우 중요한 상태들은 상태 변화 외에도 모든 이벤트를 포착하기 위해 보다 이벤트 중심적인 접근 방식을 사용하는 것이 매우 유익할 수 있습니다.

흔한 유즈 케이스는 `AuthenticationState`을 관리하는 것 입니다. 간단하게 구현하기 위해 `AuthenticationState`를 `enum`을 사용해 표현해봅시다:

[authentication_state.dart](../_snippets/core_concepts/authentication_state.dart.md ':include')

앱의 상태가 `authenticated`에서 `unauthenticated`로 바뀌는 것에는 다양한 이유가 있을 것입니다. 예를 들면, 유저가 로그아웃 버튼을 눌러서 앱의 로그아웃을 요청하는 것입니다. 반면에, 사용자의 액세스 토큰이 파기되어 강제로 로그아웃 되었을 수도 있습니다. `Bloc`을 사용하면, 애플리케이션의 상태가 어떤 이유 때문에 특정 상태로 설정되었는지 추적할 수 있습니다.

[script](../_snippets/core_concepts/authentication_transition.sh.md ':include')

위의 `Transition`은 상태가 변화된 이유에 대한 정보를 제공합니다. 만약 `AuthenticationState`를 관리하기 위해 `Cubit`을 사용했다면, 출력된 로그는 다음과 같습니다:

[script](../_snippets/core_concepts/authentication_change.sh.md ':include')

이 로그는 사용자가 로그아웃되었음을 알려주지만, 시간이 지남에 따라 애플리케이션 상태가 어떻게 변화하는지를 디버깅하고 이해하는 데 중요한 이유를 제공하지 않습니다.

#### 고급 이벤트 변환

`Bloc`이 `Cubit`을 앞서는 또 다른 영역은 `buffer`, `debounceTime`, `throttle` 등과 같은 반응형 연산자를 사용해야하는 순간 입니다.

`Bloc`은 수신되는 이벤트의 흐름을 제어하고 변환할 수 있는 이벤트 싱크가 있습니다

예를 들면, 실시간 검색을 구현할 때, 백엔드에서 rate 제한을 받지 않고 cost/load를 줄이기 위해 백엔드에 대한 요청을 debounce 하고 싶을 것입니다.

`Bloc`을 사용하면, 커스텀 `EventTransformer`를 사용하여 `Bloc`가 이벤트를 처리하는 방식을 바꿀 수 있습니다.

[counter_bloc.dart](../_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

위의 코드 처럼, 우리는 아주 적은 추가 코드로 들어오는 이벤트를 쉽게 debounce 할 수 있다.

?> 💡 **Tip**: Event transformer의 opinionated set에 대한 정보는 [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency)을 확인하세요.

?> 💡 **Tip**: 여전히 둘 중에 어떤 것을 사용해야 할지 모르겠다면, `Cubit`으로 시작하고 나중에 필요하다면 `Bloc`으로 리 팩터 또는 스케일업할 수 있습니다.
