# Tutorial de quehaceres con Firestore en Flutter

![avanzado](https://img.shields.io/badge/nivel-avanzado-red.svg)

> En el siguiente tutorial, crearemos una aplicación reactiva de quehaceres que se conecta a Firestore. Vamos a construir sobre el ejemplo [lista de quehaceres](https://bloclibrary.dev/#/fluttertodostutorial) para que no entremos en la interfaz de usuario, ya que todo será igual.

![demo](../assets/gifs/flutter_firestore_todos.gif)

Las únicas cosas que vamos a refactorizar en nuestro [ejemplo todos](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos) existente es la capa de repositorio y partes de la capa de bloc.

Comenzaremos en la capa del repositorio con el `TodosRepository`.

## Todos Repository

Cree un nuevo paquete en el nivel raíz de nuestra aplicación llamado `todos_repository`.

?> **Nota:** La razón para hacer que el repositorio sea un paquete independiente es para ilustrar que el repositorio debe estar separado de la aplicación y puede reutilizarse en múltiples aplicaciones.

Dentro de nuestro `todos_repository` cree la siguiente estructura de carpetas/archivos.

[todos_repository_dir.sh](../_snippets/flutter_firestore_todos_tutorial/todos_repository_dir.sh.md ':include')

### Dependencies

El `pubspec.yaml` debería verse así:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/todos_repository_pubspec.yaml.md ':include')

?> **Nota:** Podemos ver de inmediato que nuestro `todos_repository` depende de `firebase_core` y `cloud_firestore`.

### Package Root

El `todos_repository.dart` directamente dentro de `lib` debería verse así:

[todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/todos_repository_library.dart.md ':include')

?> Aquí es donde se exportan todas nuestras clases públicas. Si queremos que una clase sea privada para el paquete, debemos asegurarnos de omitirla.

### Entities

> Las entities(entidades) representan los datos proporcionados por nuestro proveedor de datos.

El archivo `entidades.dart` es un archivo barril que exporta el archivo `todo_entity.dart`
expediente.

[entidades.dart](../_snippets/flutter_firestore_todos_tutorial/entities_barrel.dart.md ':include')

Nuestro `TodoEntity` es la representación de nuestro `Todo` dentro de Firestore. Crea `todo_entity.dart` y vamos a implementarlo.

[todo_entity.dart](../_snippets/flutter_firestore_todos_tutorial/todo_entity.dart.md ':include')

Los métodos `toJson` y `fromJson` son estándar para convertir a/desde json. Son específicos `fromSnapshot` y `toDocument` de Firestore.

?> **Nota:** Firestore creará automáticamente el id del documento cuando lo insertemos. Como no queremos duplicar datos almacenando el id en un campo de id.

### Models

> Los modelos contendrán clases simples de dart con los que trabajaremos en nuestra aplicación Flutter. Tener la separación entre modelos y entidades nos permite cambiar nuestro proveedor de datos en cualquier momento y solo tenemos que cambiar la conversión de `toEntity` y `fromEntity` en nuestra capa de modelo.

Nuestro `models.dart` es otro archivo barril.
Dentro del `todo.dart` pongamos el siguiente código.

[todo.dart](../_snippets/flutter_firestore_todos_tutorial/todo.dart.md ':include')

### Todos Repository

> `TodosRepository` es nuestra clase base abstracta que podemos ampliar cuando queramos integrarnos con un `TodosProvider` diferente.

Creemos `todos_repository.dart`

[todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/todos_repository.dart.md ':include')

?> **Nota:** Debido a que tenemos esta interfaz, es fácil agregar otro tipo de almacén de datos. Si, por ejemplo, quisiéramos usar algo como [sembast](https://pub.dev/flutter/packages?q=sembast), todo lo que tendríamos que hacer es crear un repositorio separado para manejar el código específico de sembast.

#### Firebase Todos Repository

> `FirebaseTodosRepository` gestiona la integración con Firestore e implementa nuestra interfaz `TodosRepository`.

¡Abramos `firebase_todos_repository.dart` y lo implementamos!

[firebase_todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/firebase_todos_repository.dart.md ':include')

Eso es todo para nuestro `TodosRepository`, luego necesitamos crear un simple `UserRepository` para administrar la autenticación de nuestros usuarios.

## User Repository

Cree un nuevo paquete en el nivel raíz de nuestra aplicación llamado `user_repository`.

Dentro de nuestro `user_repository` cree la siguiente estructura de carpetas/archivos.

[user_repository_dir.sh](../_snippets/flutter_firestore_todos_tutorial/user_repository_dir.sh.md ':include')

### Dependencias

El `pubspec.yaml` debería verse así:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/user_repository_pubspec.yaml.md ':include')

?> **Nota:** Podemos ver inmediatamente que nuestro `user_repository` depende de `firebase_auth`.

### Raíz del paquete

El `user_repository.dart` directamente dentro de `lib` debería verse así:

[user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/user_repository_library.dart.md ':include')

### User Repository

> `UserRepository` es nuestra clase base abstracta que podemos ampliar cuando queramos integrarnos con un proveedor diferente.

Creemos `user_repository.dart`

[user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/user_repository.dart.md ':include')

#### Firebase User Repository

> `FirebaseUserRepository` gestiona la integración con Firebase e implementa nuestra interfaz `UserRepository`.

¡Abramos `firebase_user_repository.dart` y lo implementamos!

[firebase_user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/firebase_user_repository.dart.md ':include')

Eso es todo para nuestro `UserRepository`, luego necesitamos configurar nuestra aplicación Flutter para usar nuestros nuevos repositorios.

## Flutter App

### Setup

Creemos una nueva aplicación Flutter llamada `flutter_firestore_todos`. Podemos reemplazar el contenido de `pubspec.yaml` con lo siguiente:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/pubspec.yaml.md ':include')

?> **Nota:** Estamos agregando nuestro `todos_repository` y `user_repository` como dependencias externas.

### Authentication Bloc

Dado que queremos poder iniciar sesión en nuestros usuarios, necesitaremos crear un `AuthenticationBloc`.

?> Si aún no ha revisado el [tutorial de inicio de sesión de firebase con flutter](https://bloclibrary.dev/#/flutterfirebaselogintutorial), le recomiendo que lo revise ahora porque simplemente vamos a reutilizar el mismo `AuthenticationBloc`.

#### Authentication Events

[authentication_event.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_event.dart.md ':include')

#### Authentication States

[authentication_state.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_state.dart.md ':include')

#### Authentication Bloc

[authentication_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_bloc.dart.md ':include')

Ahora que nuestro `AuthenticationBloc` está terminado, necesitamos modificar el `TodosBloc` del [tutorial original de quehaceres](https://bloclibrary.dev/#/fluttertodostutorial) para consumir el nuevo `TodosRepository`.

### Todos Bloc

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/todos_bloc.dart.md ':include')

La principal diferencia entre nuestro nuevo `TodosBloc` y el original es que el nuevo está todo basado en `Stream` en lugar de `Future`.

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/map_load_todos_to_state.dart.md ':include')

?> Cuando cargamos nuestros quehaceres, nos suscribimos al `TodosRepository` y cada vez que entra un nuevo quehacer, agregamos un evento `TodosUpdated`. Luego manejamos todos los `TodosUpdates` a través de:

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/map_todos_updated_to_state.dart.md ':include')

## Poniéndolo todo junto

Lo último que necesitamos modificar es nuestro `main.dart`.

[main.dart](../_snippets/flutter_firestore_todos_tutorial/main.dart.md ':include')

Las principales diferencias a tener en cuenta son el hecho de que hemos envuelto toda nuestra aplicación en un `MultiBlocProvider` que inicializa y proporciona el `AuthenticationBloc` y `TodosBloc`. Entonces, solo renderizamos la aplicación de quehaceres si el `AuthenticationState` está `Authenticated` usando `BlocBuilder`. Todo lo demás permanece igual que en el tutorial anterior de quehaceres.

¡Eso es todo al respecto! Ahora hemos implementado con éxito una aplicación firestore de quehaceres en flutter usando los paquetes [bloc](https://pub.dev/packages/bloc) y [flutter_bloc](https://pub.dev/packages/flutter_bloc) y nosotros Hemos separado con éxito nuestra capa de presentación de nuestra lógica empresarial al tiempo que creamos una aplicación que se actualiza en tiempo real.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_firestore_todos).
