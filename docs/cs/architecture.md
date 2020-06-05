# Architektura

![Bloc Architecture](../assets/bloc_architecture.png)

Používání Blocu nám dovoluje rozdělit naší aplikaci do tří vrstev:

- Prezenční vrstva
- Aplikační vrstva
- Datová vrstva
  - Repositorář
  - Poskytovatel dat

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

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repozitář

> Repozitářová vrstva je obal (wrapper) nad jedním nebo vícero poskytovateli dat s kterými komunikuje Aplikační vrstva.

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

Jak můžete vidět, naše repozitářová vrstva může interagovat s vícero poskytovateli dat a provádět transformace na datech před výsledku předáním aplikační vrstvě.

## Aplikační vrstva

_Poznámka:_ název aplikační vrstva je odvozen od anglického spojení _Bloc (Business Logic) Layer_.

> Odpovědnost aplikační vrstvy je reagovat na události z prezenční vrstvy novými stavy. Aplikační vrstva může záviset na jednom nebo více repozitářích pro získání dat potřebných pro sestavení stavu aplikace.

Přemýšlejte o aplikační vrstvě jako o mostu mezi uživatelským rozhraním (prezenční vrstva) a datové vrstvě. Aplikační vrstva přijímá události generované vstupem uživatele a potom komunikuje s repozitářem za účelem vytvoření nového stavu pro prezenční vrstvu ke zpracování.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Bloc-to-Bloc komunikace

> Každý bloc má stream stavů, který mohou ostatní blocy odebírat, aby mohli reagovat na změny v rámci blocu.

Blocy mohou mít závislosti na dalších blocích aby mohli reagovat na jejich změny stavů. V následující ukázce má `MyBloc` závislost na `OtherBloc` a může `add` události jako odpověď na změnu stavů v `OtherBloc`. Aby nedošlo k úniku paměti, `StreamSubscription` je ukončeno v přepsané metode `close` v `MyBloc`.

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## Prezenční vrstva

> Odpovědnost prezenční vrstvy je zjistit, jak se vykreslit na základě jednoho nebo více blocových stavů. Kromě toho by měl zpracovat události vstupu uživatelů a životního cyklu aplikace.

Průchod většiny aplikací začne `AppStart` událostí, která spustí aplikaci a načte nějaká data k zobrazení uživateli.

V tomto scénáři by prezenční vrstva přidala `AppStart` událost.

Prezenční vrstva bude navíc muset zjistit co zobrazit na obrazovce na základě stavu z aplikační vrstvy.

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

Přestože jsme si už ukazovali nějaké útržky kódu, všechno zatím bylo docela vysokoúrovňové. V sekci tutoriálů si ukážeme jak všechno spojit dohromady a vytvoříme několik rozdílných ukázkových aplikací.
