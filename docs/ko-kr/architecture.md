# 구조

![Bloc 구조](../assets/bloc_architecture.png)

Bloc을 사용하면 어플리케이션을 3개의 layer으로 나눌 수 있게 됩니다.

- Data
  - Data Provider
  - Repository
- Business Logic
- Presentation

먼저, (User Interface에서 가장 먼) 제일 낮은 layer에서 시작해서 presentation layer까지 올라갈 예정입니다.

## Data Layer

> data layer의 역할은 소스로 부터 data를 찾고 조절하는 일입니다.

data layer은 두 부분으로 나눌 수 있습니다:

- Repository
- Data Provider

이 layer은 어플리케이션의 가장 낮은 layer으로 데이터베이스, 네트워크 요청, 비동기 데이터 소스와 상호작용합니다.

### Data Provider

> data provider는 raw data를 제공하는 역할을 합니다. data provider는 반드시 포괄적이고 다목적으로 쓰여야 합니다.

data provider는 주로 [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) 작업을 하기 위해 간단한 API를 노출합니다.
Data layer의 함수로는 보통 `createData`, `readData`, `updateData`, `deleteData`가 있을 것입니다.

```dart
class DataProvider {
    Future<RawData> readData() async {
        // Read from DB or make network request etc...
    }
}
```

### Repository

> repository layer는 data provider를 포괄해서 Bloc Layer와 소통할 수 있게 해줍니다.

```dart
class Repository {
    final DataProviderA dataProviderA;
    final DataProviderB dataProviderB;

    Future<Data> getAllDataThatMeetsRequirements() async {
        final RawDataA dataSetA = await dataProviderA.readData();
        final RawDataB dataSetB = await dataProviderB.readData();

        final Data filteredData = _filterData(dataSetA, dataSetB);
        return filteredData;
    }
}
```

위의 함수와 같이, repository layer는 여러 data provider와 상호작용할 수 있으며 결과값을 business logic layer에 전달하기 전에 data를 변모시키기도 합니다.

## Bloc (Business Logic) Layer

> bloc layer의 역할은 presentation layer으로 부터 발생한 event를 새로운 state로 변화시킵니다. bloc layer은 application의 state를 만들기 위해 한개 이상의 repository에 의존하여 필요한 data를 얻어낼 수도 있습니다.

bloc layer을 유저 인터페이스(presentation layer)와 data layer 사이의 연결 다리라고 생각하면 될 것 같습니다. bloc layer은 user input으로 생성된 event를 받아 presentation layer에게 제공할 새로운 state를 만들기 위해 repository와 소통합니다.

```dart
class BusinessLogicComponent extends Bloc<MyEvent, MyState> {
    final Repository repository;

    Stream mapEventToState(event) async* {
        if (event is AppStarted) {
            try {
                final data = await repository.getAllDataThatMeetsRequirements();
                yield Success(data);
            } catch (error) {
                yield Failure(error);
            }
        }
    }
}
```

### Bloc-to-Bloc Communication

> 모든 bloc은 bloc의 변화에 반응할 수 있게 다른 bloc이 구독할 수 있는 state stream이 있습니다.

Blocs can have dependencies on other blocs in order to react to their state changes. In the following example, `MyBloc` has a dependency on `OtherBloc` and can `add` events in response to state changes in `OtherBloc`. The `StreamSubscription` is closed in the `close` override in `MyBloc` in order to avoid memory leaks.

Bloc은 state 변화에 대응하기 위해 다른 bloc에 의존성을 가지고 있을 수 있습니다. 다음 예시에서는, `MyBloc`은 `OtherBloc`에 의존성을 가지고 있으며 `OtherBloc`에서 발생하는 state 변화에 event를 `추가`할 수 있습니다. `StreamSubscription`는 메모리가 세는 것을 방지하기 위해 `MyBloc` 내의 `close` 함수에서 close가 가능합니다.

```dart
class MyBloc extends Bloc {
  final OtherBloc otherBloc;
  StreamSubscription otherBlocSubscription;

  MyBloc(this.otherBloc) {
    otherBlocSubscription = otherBloc.listen((state) {
        // React to state changes here.
        // Add events here to trigger changes in MyBloc.
    });
  }

  @override
  Future<void> close() {
    otherBlocSubscription.cancel();
    return super.close();
  }
}
```

## Presentation Layer

> presentation layer는 bloc state에 따라 유저에게 어떻게 보여줄지를 결정합니다. 게다라, 유저의 input과 어플리케이션의 lifecycle event를 제어합니다.

대부분의 어플리케이션의 진행은 어플리케이션이 유저에게 보여줄 정보를 가져오게 하는 `AppStart` event에서 부터 시작합니다.

이 시나리오에서, presentation layer는 `AppStart` event를 추가시킵니다.

그리고 presentation layer는 bloc layer로부터 온 state에 따라 무엇을 보여줄지 결정합니다.

```dart
class PresentationComponent {
    final Bloc bloc;

    PresentationComponent() {
        bloc.add(AppStarted());
    }

    build() {
        // render UI based on bloc state
    }
}
```

여기까지, 코드의 일부만 살펴보았지만, 이것은 꽤 높은 수준의 내용입니다. 튜토리얼 섹션에서 다른 예제 앱을 만들어 보며 살펴본 내용을 응용해보겠습니다.