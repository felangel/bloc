# Foire aux questions

## Le state ne s'actualise pas

❔ **Question**: J'effectue un yield sur un state dans mon bloc mais mon UI ne s'actualise pas. Qu'est-ce que je fais de mal ?

💡 **Réponse**: Si vous utilisez Equatable, assurez vous de passer toutes les propriétés au getter props.

✅ **BON**

[my_state.dart](../_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **MAUVAIS**

[my_state.dart](../_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](../_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

En plus de cela, assurez vous de yield une nouvelle instance de votre state dans votre bloc.

✅ **BON**

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **MAUVAIS**

[my_bloc.dart](../_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

## Quand utiliser Equatable ?

!> Les propriétés de `Equatable` devraient toujours être copiées plutôt que modifiées. Si une classe `Equatable` contient une `List` ou une `Map` comme propriété, assurez vous d'utiliser `List.from` ou `Map.from` respectivement pour vous assurer que l'égalité est évalué sur la base des valeurs des propriétés plutôt que la référence.

❔**Question**: Quand est-ce que je dois utiliser Equatable ?

💡**Réponse**:

[my_bloc.dart](../_snippets/faqs/equatable_yield.dart.md ':include')

Dans le scénario du dessus si `StateA` étend `Equatable` un seul changement de state aura lieu(le deuxième yield sera ignoré).
En général, vous devriez utiliser `Equatable` si vous voulez optimiser votre code pour réduire le nombre de reconstructions (rebuilds).
Vous ne devriez pas `Equatable` si vous voulez que le même state déclenche coup sur coup de multiples transitions.

En plus de cela, utiliser `Equatable` facilite le testing sur les blocs puisque qu'on le peut attendre des instances spécifiques des blocs states plutôt que d'utiliser des `Matchers` ou `Predicates`.

[my_bloc_test.dart](../_snippets/faqs/equatable_bloc_test.dart.md ':include')

Sans `Equatable` le test du dessus échouera et aura besoin d'être réécrit de la manière suivante:

[my_bloc_test.dart](../_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

## Gestion des erreurs

  ❔ **Question**: Comment puis-je gérer une erreur tout en affichant les données précédentes ?

  💡 **Réponse**:

  Cela dépend fortement de la manière dont l'état du bloc a été modélisé. Dans les cas où les données doivent encore être conservées même en présence d'une erreur, vous pouvez utiliser une seule classe d'état.

  ```dart
 enum Status { initial, loading, success, failure }

 class MyState {
   const MyState({
     this.data = Data.empty,
     this.error = '',
     this.status = Status.initial,
   });

   final Data data;
   final String error;
   final Status status;

   MyState copyWith({Data data, String error, Status status}) {
     return MyState(
       data: data ?? this.data,
       error: error ?? this.error,
       status: status ?? this.status,
     );
   }
 }
 ```

  Cela permettra aux widgets d'avoir accès aux propriétés `data` et` error` simultanément en utilisant le constructeur `state.copyWith` pour conserver les anciennes données même lorsqu'une erreur s'est produite.

  ```dart
 if (event is DataRequested) {
   try {
     final data = await _repository.getData();
     yield state.copyWith(status: Status.success, data: data);
   } on Exception {
     yield state.copyWith(status: Status.failure, error: 'Something went wrong!');
   }
 }
 ```

## Bloc vs. Redux

❔ **Question**: Quelle est la différence entre Bloc et Redux ?

💡 **Réponse**:

BLoC est un patron de conception (design pattern) qui est défini selon les règles suivantes :

1. Input et Output du BloC sont des simples Streams et Sinks.
2. Les dépendances doivent être injectables et s'adapter aux plateformes (iOs, Android and Web).
3. Aucune logique doit dépendre sur la plateforme sur laquelle on se trouve.
4. L'implementation est libre tant que vous suivez les règles cités ci-dessus.

Les lignes directrices pour l'UI sont:

1. Chaque composant "assez compliqué" a un BloC qui lui correspond.
2. Les composants doivent renvoyer les input (entrées) doivent être envoyées "comme tel".
3. Les composants devraient afficher les outputs (sorties) aussi proche de "comme tel".
4. All branching should be based on simple BLoC boolean outputs.

La Librairie Bloc implémente le Design Pattern Bloc et vise à abstraire RxDart dans le but de simplifier l'expérience de développement.

Les trois principes de Redux sont:

1. Une seule source de confiance
2. Le state est en lecture-seul
3. Les changements sont faits avec des fonctions pures.

La librairie Bloc enfreint le premier principe; avec le state bloc qui est distribué à travers de multiples blocs.
Par ailleurs, il n'y a pas de concept de middleware [définition](https://fr.wikipedia.org/wiki/Middleware) dans bloc et bloc est designé pour faire des changements de state async de manière très simple, ce qui nous permet d'émettre de multiples states pour un seul événement.

## Bloc vs. Provider

❔ **Question**: Quelle est la différence entre Bloc et Provider ?

💡 **Réponse**: `Provider` est utilisé pour l'injection de dépendances (dependency injection) (il enveloppe `InheritedWidget`).
Vous allez toujours avoir besoin de gérer votre state (via `ChangeNotifier`, `Bloc`, `Mobx`, etc...).
La librairie Bloc utilise `Provider` en interne pour permettre de fournir et d'accèder aux blocs dans tout l'arbre de widgets.

## Naviguer avec Bloc

❔ **Question**: Comment naviguer avec Bloc ?

💡 **Réponse**: Visitez [Flutter Navigation](recipesflutternavigation.md)

## BlocProvider.of() échoue à trouver le Bloc

❔ **Question**: Quand j'utilise `BlocProvider.of(context)`il n'arrive pas à trouver mon bloc. Comment puis-je régler cela ?

💡 **Réponse**: Vous ne pouvez pas accèder au bloc depuis le même contexte que celui dans lequel il a été renseigné. Vous devez donc vous assurer que `BlocProvider.of()` est bien appelé à l'intérieur de l'enfant(child) `BuildContext`.

✅ **BON**

[my_page.dart](../_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](../_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **MAUVAIS**

[my_page.dart](../_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## Structure d'un projet

❔ **Question**: Comment dois-je structurer mon projet ?

💡 **Réponse**: Il n'y a pas vraiment de bonne/mauvaise réponse à cette question, voici quelques références que je peux vous recommander : 

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

La chose la plus importante est d'avoir une structure de projet **consistante** et **intentionnel**.
