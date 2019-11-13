# Architektura

![Bloc Architecture](../assets/bloc_architecture.png)

Používání Blocu nám dovoluje rozdělit naší aplikaci do tří vrstev:

- Datová vrstva
  - Poskytovatel dat
  - Repositorář
- Aplikační vrstva
- Prezenční vrstva

Začneme na nejnižší vrstvě (nejdále od uživatelského rozhraní) a vypracujeme se až do prezenční vrstvy.

## Datová vrstva

> Odpovědnost datové vrstvy je získat a manipulovat s daty z jednoho nebo více zdrojů.

Datová vrstva může být rozdělena na dvě části:

- Poskytovatel dat
- Repozitář

Tato vrstva je nejnižší úroveň aplikace a interaguje s databází, síťovými požadavky a ostatními asynchronními datovými zdroji.

### Poskytovatel dat

> Odpovědnost Poskytovatele dat je poskytnout syrová data. Poskytovatel dat by měl být obecný a univerzální.

Poskytovatel dat bude obvykle odhalovat jednoduchá API pro provádění [CRUD](https://cs.wikipedia.org/wiki/CRUD) operací. Jako součást naší datové vrstvy tak můžeme mít metody `createData`, `readData`, `updateData` a `deleteData`.

```dart
class DataProvider {
    Future<RawData> readData() async {
        // Read from DB or make network request etc...
    }
}
```

### Repozitář

> Repozitářová vrstva je obal (wrapper) nad jedním nebo vícero poskytovateli dat s kterými komunikuje Aplikační vrstva.

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

Jak můžete vidět, naše repozitářová vrstva může interagovat s vícero poskytovateli dat a provádět transformace na datech před výsledku předáním aplikační vrstvě.

## Aplikační vrstva

*Poznámka:* název aplikační vrstva je odvozen od anglického spojení *Bloc (Business Logic) Layer*.

> Odpovědnost aplikační vrstvy je reagovat na události z prezenční vrstvy novými stavy. Aplikační vrstva může záviset na jednom nebo více repozitářích pro získání dat potřebných pro sestavení stavu aplikace.

Přemýšlejte o aplikační vrstvě jako o mostu mezi uživatelským rozhraním (prezenční vrstva) a datové vrstvě. Aplikační vrstva přijímá události generované vstupem uživatele a potom komunikuje s repozitářem za účelem vytvoření nového stavu pro prezenční vrstvu ke zpracování.

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

### Bloc-to-Bloc komunikace

> Každý bloc má stream stavů, který mohou ostatní blocy odebírat, aby mohli reagovat na změny v rámci blocu.

Blocy mohou mít závislosti na dalších blocích aby mohli reagovat na jejich změny stavů. V následující ukázce má `MyBloc` závislost na `OtherBloc` a může `add` události jako odpověď na změnu stavů v `OtherBloc`. Aby nedošlo k úniku paměti, `StreamSubscription` je ukončeno v přepsané metode `close` v `MyBloc`.

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

## Prezenční vrstva

> Odpovědnost prezenční vrstvy je zjistit, jak se vykreslit na základě jednoho nebo více blocových stavů. Kromě toho by měl zpracovat události vstupu uživatelů a životního cyklu aplikace.

Průchod většiny aplikací začne `AppStart` událostí, která spustí aplikaci a načte nějaká data k zobrazení uživateli.

V tomto scénáři by prezenční vrstva přidala `AppStart` událost.

Prezenční vrstva bude navíc muset zjistit co zobrazit na obrazovce na základě stavu z aplikační vrstvy.

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

Přestože jsme si už ukazovali nějaké útržky kódu, všechno zatím bylo docela vysokoúrovňové. V sekci tutoriálů si ukážeme jak všechno spojit dohromady a vytvoříme několik rozdílných ukázkových aplikací.
