# Testování

> Bloc byl navržen tak, aby byl velmi lehce testovatelný.

Pro jednoduchost si napíšeme testy pro `CounterBloc`, který jsme vytvořili v [Základních konceptech](cs/coreconcepts.md)

Pro rekapitulaci, implementace `CounterBlocu` vypadá takto

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Před tím, než začneme psát naše testy, budeme potřebovat přidat testovací framework do našich závislostí.

Potřebujeme přidat [test](https://pub.dev/packages/test) a [bloc_test](https://pub.dev/packages/bloc_test) do našeho `pubspec.yaml`.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

Začneme vytvořením souboru pro náš `CounterBloc` test, `counter_bloc_test.dart`, a importujeme balíček test.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Jako další si vytvoříme náš `main` stejně jako naši skupinu testů.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Poznámka**: skupiny jsou pro organizaci jednotlivých testů stejně jako pro vytváření kontextu, ve kterém můžete sdílet společný `setUp` a `tearDown` napříč všemi jednotlivými testy.

Začneme vytvořením instance našeho `CounterBlocu`, který bude použit napříč všemi testy.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Nyní můžeme začít psát naše jednotlivé testy.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Poznámka**: Můžeme spustit všechny naše testy pomocí příkazu `pub run test`.

V tomto bodě bychom měli mít náš první průchozí test! Nyní si napíšeme složitější test pomocí balíčku [bloc_test](https://pub.dev/packages/bloc_test).

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Měli bychom být schopni spustit testy a vidět, že prochází.

To je všechno, testování by mělo být hračkou a měli bychom se cítit sebejistě, když děláme změny a refaktorujeme náš kód.

Příklad plně otestované aplikace můžete nalézt v [Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library).
