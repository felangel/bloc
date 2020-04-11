# Často kladené otázky

## Stav se neupdatuje

❔ **Otázka**: Yielduji stav v mém blocu, ale UI se neupdatuje. Co dělám špatně?

💡 **Odpověď**: Pokud používáte Equatable, ujistěte se, že předáváte všechny vlastnosti do props getteru.

✅ **SPRÁVNĚ**

[my_state.dart](../_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **ŠPATNĚ**

[my_state.dart](../_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](../_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

Také se ujistěte, že v blocu yieldujete novou instancu stavu.

✅ **SPRÁVNĚ**

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **ŠPATNĚ**

[my_bloc.dart](../_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

## Kdy použít Equatable

❔**Otázka**: Kdy používat Equatable?

💡**Odpověď**:

[my_bloc.dart](../_snippets/faqs/equatable_yield.dart.md ':include')

V ukázce výše, pokud `StateA` rozšiřuje `Equatable`, nastane pouze jeden stav (druhý yield bude ignorován).
Obecně, pokud chcete optimalizovat váš kód, byste měli používat `Equatable` k redukování počtu znovusestavení.
Neměli byste používat `Equatable`, pokud chcete, aby stejný stav spouštěl více transakcí.

Navíc, použitím `Equatable` si ulehčíte testování bloců, jelikož můžeme očekávat specifické instance stavů bloku spíše než pomocí `Matchers` nebo `Predicates`.

[my_bloc_test.dart](../_snippets/faqs/equatable_bloc_test.dart.md ':include')

Bez `Equatable` by test výše selhal a musel by být přepsán takto:

[my_bloc_test.dart](../_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

## Bloc vs. Redux

❔ **Otázka**: Jaký je rozdíl mezi Blocem a Reduxem?

💡 **Odpověď**:

BLoC je návrhový vzor, který je definovaný následujícími pravidly:

1. Vstup a výstup z blocu jsou jednoduché streamy a sinky.
2. Závislosti musí být injektovatelné a nezávislé na platformě.
3. Není povoleno žádné větvení kvůli platformě.
4. Implementace může být cokoli co chcete, pokud budete dodržovat výše uvedená pravidla.

UI pokyny jsou:

1. Každá "dostatečně komplexní" komponenta má příslušný BLoC.
2. Komponenty by měly posílat vstupy "jak jsou".
3. Komponenty by měly zobrazovat výstupy co nejblíže tomu, "jaké jsou".
4. Všechno větvění by mělo být založeno na jednoduchých BLoC boolean hodnotách.

Knihovna Bloc implementuje BLoC návrhový vzor a klade si za cíl abstrahovat RxDart a zjednodušit vývojářský zážitek. 

Tři principy Reduxu jsou:

1. Jeden zdroj pravdy
2. Stav je pouze ke čtení
3. Změny se provádějí pomocí pure funkcí

Knihovna Bloc porušuje první princip; v blocu je stav distrubován napříč několika blocy.
Kromě toho neexistuje v blocu žádný koncept middlewaru a bloc je navržen tak, aby byly asynchronního změny stavu velmi snadné, což umožňuje emitovat více stavů pro jednu událost.

## Bloc vs. Provider

❔ **Otázka**: Jaký je rozdíl mezi Blocem a Providerem?

💡 **Odpověď**: `provider` je navržen pro dependency injection (obaluje `InheritedWidget`).
Pořád potřebujete vyřešit jak spravovat váš stav (pomocí `ChangeNotifier`, `Bloc`, `Mobx`, atp...).
Knihovna Bloc vnitřně používá `provider` pro snadné poskytnutí a přístup k blocům skrze strom widgetů.

## Navigace s Blocem

❔ **Otázka**: Jak udělám navigaci s Blocem?

💡 **Odpověď**: Mrkněte na [Flutter Navigaci](recipesflutternavigation.md)

## BlocProvider.of() nezvládá najít Bloc

❔ **Otázka**: Použitím `BlocProvider.of(context)` nenajdu bloc. Jak to vyřešit? 

💡 **Odpověď**: Nemůžete přistupovat k bloku ve stejném kontextu, ve kterém byl poskytnut, takže musíte zajistit, aby `BlocProvider.of()` byl zavolán v `BuildContext` potomka.

✅ **SPRÁVNĚ**

[my_page.dart](../_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](../_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **ŠPATNĚ**

[my_page.dart](../_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## Struktura projektu

❔ **Otázka**: Jak mám strukturovat svůj projekt?

💡 **Odpověď**: Ikdyž na tuto otázku opravdu není žádná správná/špatná odpověď, některá doporučení jsou

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Nejdůležitější věc je mít stukturu projektu konzisentní a úmyslnou.
