# Tutorial de Contador en AngularDart

![beginner](https://img.shields.io/badge/nivel-principiante-green.svg)

> En el siguiente tutorial, vamos a construir un contador en AngularDart usando la biblioteca Bloc.

![demo](../assets/gifs/angular_counter.gif)

## Para empezar

Comenzaremos creando un nuevo proyecto en AngularDart con [stagehand](https://github.com/dart-lang/stagehand).

[script](../_snippets/angular_counter_tutorial/stagehand.sh.md ':include')

!> Activar stagehand ejecutando `pub global activate stagehand`

Luego podemos continuar y reemplazar el contenido de `pubspec.yaml` con:

[pubspec.yaml](../_snippets/angular_counter_tutorial/pubspec.yaml.md ':include')

y luego instale todas nuestras dependencias

[script](../_snippets/angular_counter_tutorial/install.sh.md ':include')

Nuestra aplicación de contador solo tendrá dos botones para incrementar/disminuir el valor del contador y un elemento para mostrar el valor actual. Comencemos a diseñar los `CounterEvents`.

## Counter Events

[counter_event.dart](../_snippets/angular_counter_tutorial/counter_event.dart.md ':include')

## Counter States

Dado que el estado de nuestro contador puede ser representado por un número entero, ¡No necesitamos crear una clase personalizada!

## Counter Bloc

[counter_bloc.dart](../_snippets/angular_counter_tutorial/counter_bloc.dart.md ':include')

?> **Nota**: Solo mirando la declaración de la clase podemos decir que nuestro `CounterBloc` tomará `CounterEvents` como números enteros de entrada y salida.

## Counter App

Ahora que tenemos nuestro `CounterBloc` completamente implementado, podemos comenzar a crear nuestro componente de aplicación AngularDart.

Nuestro `app.component.dart` debería verse así:

[app.component.dart](../_snippets/angular_counter_tutorial/app_component.dart.md ':include')

Y nuestro `app.component.html` debería verse así:

[app.component.html](../_snippets/angular_counter_tutorial/app_component.html.md ':include')

## Counter Page

Finalmente, todo lo que queda es construir nuestro componente de página de contador.

Nuestro `counter_page_component.dart` debería verse así:

[counter_page_component.dart](../_snippets/angular_counter_tutorial/counter_page_component.dart.md ':include')

?> **Nota**: Podemos acceder a la instancia de `CounterBloc` usando el sistema de inyección de dependencias de AngularDart. Debido a que lo hemos registrado como un `Proveedor`, AngularDart puede resolver correctamente `CounterBloc`.

?> **Nota**: Estamos cerrando el `CounterBloc` en `ngOnDestroy`.

?> **Nota**: Estamos importando el `BlocPipe` para que podamos usarlo en nuestra plantilla.

Por último, nuestro `counter_page_component.html` debería verse así:

[counter_page_component.html](../_snippets/angular_counter_tutorial/counter_page_component.html.md ':include')

?> **Nota**: Estamos usando el `BlocPipe` para que podamos mostrar nuestro estado `CounterBloc` a medida que se actualiza.

¡Eso es! Hemos separado nuestra capa de presentación de nuestra capa de lógica empresarial. Nuestro `CounterPageComponent` no tiene idea de lo que sucede cuando un usuario presiona un botón; simplemente agrega un evento para notificar al `CounterBloc`. Además, nuestro `CounterBloc` no tiene idea de lo que está sucediendo con el estado (el valor del contador); es simplemente convertir los `CounterEvents` en números enteros.

Podemos ejecutar nuestra aplicación con `webdev serve` y podemos verla [localmente](http://localhost:8080).

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).
