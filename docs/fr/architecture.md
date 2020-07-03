# Architecture

![Bloc Architecture](../assets/bloc_architecture.png)

L'utilisation de Bloc nous permet de séparer notre application en trois couches :

- Présentation
- Logique métier
- Données
  - Repository (Dépôt)
  - DataProvider (Fournisseur de données)

Nous allons commencer par le niveau le plus bas (le plus éloigné de l'interface utilisateur) et remonter jusqu'à la couche de présentation.

## Couche de données

> La responsabilité de la couche de données est de récupérer/manipuler les données d'une ou plusieurs sources.

La couche de données peut être divisée en deux parties :

- Dépôt
- Fournisseur de données

Cette couche est le niveau le plus bas de l'application et interagit avec les bases de données, les requêtes réseau et autres sources de données asynchrones.

### DataProvider (Fournisseur des données)

> La responsabilité du DataProvider est de fournir des données brutes. Le DataProvider doit être générique et polyvalent.

Le DataProvider expose généralement des API simples pour effectuer [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) des opérations.
Nous pourrions avoir des méthodes `createData`, `readData`, `updateData`, et `deleteData` dans notre couche de données.

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repository (Dépôt)

> La couche Repository est une enveloppe autour d'un ou plusieurs DataProvider avec lesquels le Bloc Layer communique.

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

Comme vous pouvez le voir, notre couche Repository peut interagir avec plusieurs DataProviders et effectuer des transformations sur les données avant de les transmettre à la couche chargée de la logique métier.

## Bloc (Business Logic) Layer (Couche logique métier)

> La responsabilité de la couche bloc est de répondre aux événements de la couche présentation avec de nouveaux états. La couche bloc peut dépendre d'un ou plusieurs Repository pour récupérer les données nécessaires à la construction de l'état courante de l'application.

Pensez à la couche bloc comme le pont entre l'interface utilisateur (couche de présentation) et la couche de données. La couche bloc prend les événements générés par l'entrée utilisateur et communique ensuite avec le Repository afin de construire un nouvel état pour la couche de présentation à consommer.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Communication Bloc à Bloc

> Chaque bloc dispose d'un stream auquel d'autres blocs peuvent souscrire afin de réagir aux changements au sein du bloc.

Les blocs peuvent avoir des dépendances avec d'autres blocs afin de réagir à leurs changements d'état. Dans l'exemple suivant, `MyBloc` a une dépendance à l'égard de `OtherBloc` et peut `dispatch` en réponse à des changements d'état dans les activités dans `OtherBloc`. Le `StreamSubscription` est fermé dans `dispose` dans `MyBloc` afin d'éviter les fuites de mémoire.

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## Couche de présentation

> La responsabilité de la couche de présentation est d'afficher son contenu en fonction d'un ou plusieurs états du bloc. En outre, il doit gérer les entrées des utilisateurs et les événements durant les cycles de vie de l'application.

La plupart des applications commenceront par un événement `AppStart` qui déclenchera la récupération des données pour les présenter à l'utilisateur.

Dans ce scénario, la couche de présentation envoit un événement `AppStart`.

De plus, la couche de présentation devra déterminer ce qu'il faut afficher à l'écran en fonction de l'état de la couche bloc.

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

Jusqu'à présent, même si nous avons vu quelques bribes de code, tout cela est d'un niveau assez élevé. Dans la section tutoriel, nous allons mettre tout cela ensemble en construisant plusieurs exemples d'applications différentes.
