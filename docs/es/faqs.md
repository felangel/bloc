# Preguntas Frecuentes

## Estado no se está actualizando

❔ **Pregunta**: Estoy produciendo un estado en mi bloc pero la interfaz de usuario no se está actualizando. ¿Qué estoy haciendo mal?

💡 **Respuesta**: Si está utilizando Equatable, asegúrese de pasar todas las propiedades al props getter.

✅ **BIEN**

[my_state.dart](../_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **MAL**

[my_state.dart](../_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](../_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

Además, asegúrese de obtener una nueva instancia del estado en su bloc.

✅ **BIEN**

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **MAL**

[my_bloc.dart](../_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

!> Las propiedades `Equatable` siempre deben copiarse en lugar de modificarse. Si una clase `Equatable` contiene una `Lista` o `Mapa` como propiedades, asegúrese de usar `List.from` o `Map.from` respectivamente para asegurarse de que la igualdad se evalúa basada en los valores de las propiedades en vez de la referencia.

## Cuando usar Equatable

❔**Pregunta**: ¿Cuándo debo usar Equatable?

💡**Respuesta**:

[my_bloc.dart](../_snippets/faqs/equatable_yield.dart.md ':include')

En el escenario anterior, si `StateA` extiende `Equatable` solo se producirá un cambio de estado (se ignorará el segundo "yield"). En general, debe usar `Equatable` si desea optimizar su código para reducir el número de reconstrucciones. No debe usar `Equatable` si desea que el mismo estado de forma consecutiva desencadene múltiples transiciones.

Además, el uso de `Equatable` hace que sea mucho más fácil probar bloc, ya que podemos esperar instancias específicas de estados de bloc en lugar de usar `Matchers` o `Predicates`.

[my_bloc_test.dart](../_snippets/faqs/equatable_bloc_test.dart.md ':include')

Sin `Equatable`, la prueba anterior fallaría y necesitaría reescribirse como:

[my_bloc_test.dart](../_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

## Bloc vs. Redux

❔ **Pregunta**: ¿Cuál es la diferencia entre Bloc y Redux?

💡 **Respuesta**:

BLoC es un patrón de diseño que se define mediante las siguientes reglas:

1. La entrada y salida de BLoC son simples Streams y Sinks.
2. Las dependencias deben ser inyectables y agnósticas a la plataforma.
3. No se permite la ramificación de la plataforma.
4. La implementación puede ser lo que quieras siempre y cuando sigas las reglas anteriores.

Las pautas de UI son:

1. Cada componente "suficientemente complejo" tiene un BLoC correspondiente.
2. Los componentes deben enviar entradas "tal cual".
3. Los componentes deben mostrar las salidas lo más cerca posible de "tal cual".
4. Todas las ramificaciones deben basarse en salidas booleanas BLoC simples.

La Biblioteca de Bloc implementa el patrón de diseño BLoC y tiene como objetivo abstraer RxDart para simplificar la experiencia del desarrollador.

Los tres principios de Redux son:

1. Única fuente fiable
2. El estado es de solo lectura
3. Los cambios se realizan con funciones puras.

La biblioteca de bloc viola el primer principio; con el estado de bloc que se distribuye en múltiples blocs.
Además, no hay un concepto de middleware en bloc y el bloc está diseñado para hacer que los cambios de estado asíncrono sean muy fáciles, lo que le permite emitir múltiples estados para un solo evento.

## Bloc vs. Provider

❔ **Pregunta**: ¿Cuál es la diferencia entre Bloc y Provider?

💡 **Respuesta**: `provider` está diseñado para inyección de dependencia (envuelve` InheritedWidget`). Aún necesita descubrir cómo administrar su estado (a través de `ChangeNotifier`,` Bloc`, `Mobx`, etc.). La Biblioteca de Bloc utiliza internamente el "provider" para facilitar el suministro y el acceso a los bloques en todo el árbol de widgets.

## Navegación con Bloc

❔ **Pregunta**: ¿Cómo hago la navegación con Bloc?

💡 **Respuesta**: Echa un vistazo a [Navegación con Flutter](recipesflutternavigation.md)

## BlocProvider.of() Falla al encontrar bloc

❔ **Pregunta**: Cuando se usa `BlocProvider.of (context)` no puede encontrar el bloque. ¿Cómo puedo arreglar esto?

💡 **Respuesta**: No puede acceder a un bloc desde el mismo contexto en el que se proporcionó, por lo que debe asegurarse de que se llame a `BlocProvider.of ()` dentro de un elemento secundario `BuildContext`.

✅ **GOOD**

[my_page.dart](../_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](../_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **BAD**

[my_page.dart](../_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## Estructura del proyecto

❔ **Question**: ¿Cómo debo estructurar mi proyecto?

💡 **Answer**: Si bien realmente no hay una respuesta correcta / incorrecta a esta pregunta, algunas referencias recomendadas son

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Lo más importante es tener una estructura de proyecto **consistente** e **intencional**.
