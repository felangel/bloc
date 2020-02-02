# Архитектура

![Архитектура блока](../assets/bloc_architecture.png)

Использование `bloc` позволяет нам разделить наше приложение на три слоя:

- Data (Данные)
  - Data Provider (Поставщик данных)
  - Repositopy (Хранилище)
- Business Logic (Бизнес логика)
- Presentation (Представление)

Мы начнем с самого нижнего уровня (самого дальнего от пользовательского интерфейса) и перейдем к уровню представления.

## Data Layer (Слой данных)

> Ответственность уровня данных заключается в извлечении/манипулировании данными из одного или нескольких источников.

Слой данных можно разделить на две части:

- Repository (Хранилище)
- Data Provider (Поставщик данных)

Этот уровень является самым низким уровнем приложения и взаимодействует с базами данных, сетевыми запросами и другими асинхронными источниками данных.

### Data Provider (Поставщик данных)

> Ответственность поставщика данных заключается в предоставлении необработанных данных. Поставщик данных должен быть универсальным.

Поставщик данных обычно предоставляет простые API для выполнения операций [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete). Мы могли бы иметь методы `createData`, `readData`, `updateData` и `deleteData` как часть нашего уровня данных.

```dart
class DataProvider {
    Future<RawData> readData() async {
        // Read from DB or make network request etc...
    }
}
```

### Repository (Хранилище)

> Уровень хранилища представляет собой оболочку вокруг одного или нескольких поставщиков данных, с которыми связывается уровень `Bloc`.

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

Как видите, наш уровень хранилища может взаимодействовать с несколькими поставщиками данных и выполнять преобразования данных перед передачей результата на уровень бизнес-логики.

## Слой Bloc (слой бизнес логики)

> Ответственность уровня блока заключается в том, чтобы отвечать на события из уровня представления новыми состояниями. Уровень блока может зависеть от одного или нескольких хранилищ для извлечения данных, необходимых для создания состояния приложения.

Думайте о `bloc` уровне как о мосте между пользовательским интерфейсом (уровень представления) и уровнем данных (data layer). Слой блока принимает события, сгенерированные пользовательским вводом, а затем связывается с репозиторием, чтобы создать новое состояние для уровня представления для дальнейшего использования.

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

### Взаимодействие между блоками

> Каждый `bloc` имеет поток состояний, на который могут подписаться другие блоки, чтобы реагировать на изменения внутри себя.

`Blocs` могут зависеть от других `blocs`, чтобы реагировать на изменения их состояния. В следующем примере `MyBloc` зависит от `OtherBloc` и может добавлять события в ответ на изменения состояния в `OtherBloc`. `StreamSubscription` закрывается в переопределении `close` в `MyBloc`, чтобы избежать утечек памяти.

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

## Слой представления

> Ответственность уровня представления состоит в том, чтобы выяснить, как визуализировать себя на основе одного или нескольких состояний `bloc`. Кроме того, он должен обрабатывать пользовательский ввод и события жизненного цикла приложения.

Большинство приложений начинается с события `AppStart`, которое при запуске сначала извлекает необходимые данные, представляемые пользователю.

В этом сценарии уровень представления добавил бы событие `AppStart`.

Кроме того, слой представления должен будет выяснить, что визуализировать на экране на основе состояния слоя `bloc`.

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

Пока что, несмотря на то, что у нас уже имелись некоторые фрагменты кода, все это было на довольно высоком уровне. В этом же разделе мы соберем все вместе когда создадим несколько примеров приложений.
