# Arquitectura

![Bloc Architecture](../assets/bloc_architecture.png)

Utilizando **BLoC** nos permite separar nuestra aplicación en tres capas:

- Presentación
- Lógica de Negocio
- Datos
    - Repositorio
    - Proveedor de datos

Comenzaremos a trabajar con la capa de nivel más bajo (la más alejada de la interfaz de usuario) hasta llegar a la capa de presentación.

## Capa de Datos

> La capa de datos es la responsable de acceder y manipular los datos de una o mas fuentes.

La capa de datos se puede dividir en dos partes:

- Proveedor de datos
- Repositorio

Esta capa es el nivel más bajo de la aplicación e interactúa con bases de datos, solicitudes de red y otras fuentes de datos asíncronas.

### Proveedor de Datos

> El proveedor de datos es el responsable de proporcionar datos en bruto, es decir, sin procesar. El proveedor de datos debe ser genérico y versatil .

El proovedor de datos usualmente expone simples API para operaciones de creación, lectura, actualización y borrado (conocido como [CRUD](https://es.wikipedia.org/wiki/CRUD)). Podemos tener un metodo `createData` (crear), `readData` (leer), `updateData` (actualizar) y `deleteData` (eliminar) como parte de nuestra capa de datos.

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repositorio

> La capa de repositorio es un contenedor de uno o mas proveedores de datos con los cuales se comunica la capa del Bloc.

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

Como puedes observar, la capa de repositorio puede interactuar con multiples proveedores de datos y realizar transformaciones en los datos antes de servir los resultados a la capa lógica.

## Capa Bloc (Lógica de Negocio)

> La capa Bloc es responsable de responder con nuevos estados a los eventos de la capa de presentación. La capa Bloc puede depender en uno o más repositorios para obtener los datos necesarios para construir el estado de la aplicación.

Piensa en la capa Bloc como el puente entre la interfaz de usuario (capa de presentación) y la capa de datos. La capa Bloc toma los eventos generados por entradas de usuario y asi comunicarse con el repositorio con el fin de construir un nuevo estado para ser consumido por la capa de presentación.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Comunicación Bloc-a-Bloc

> Todos los Bloc tienen un flujo de estados a los cuales pueden subscribirse otros Blocs con el fin de reaccionar a los cambios del mismo.

Los Bloc pueden tener dependencia en otros Blocs con el fin de reaccionar a cambios en sus estados. En el siguiente ejemplo, `MyBloc` tiene una dependencia en `OtherBloc` y pueden agregar (`add`) eventos en respuesta a los cambios de estado en `OtherBloc`. La subscripción (`StreamSubscription`) es cerrada en el método modificado `close` con el fin de evitar [fugas de memoria](https://es.wikipedia.org/wiki/Fuga_de_memoria).

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## Capa de Presentación

> La capa de presentación es la responsable de presentar el sistema al usuario, basandose en los estados de uno o mas Blocs. Además, debe manejar las entradas de usuario y los eventos del ciclo de vida de la aplicación.

Muchos flujos de aplicaciones comienzan con un evento de inicio (`AppStart`) el cual desencadena la obtención de datos por parte de la aplicación para ser presentados al usuario de manera amigable.

En este escenario, la capa de presentación debe agregar el evento `AppStart`.

Además, la capa de presentación debe saber representar en la pantalla de acuerdo al estado proveniente de la capa lógica (Bloc).

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

Hasta ahora, a pesar de que hemos tenido algunos fragmentos de código, todo esto ha sido de alto nivel. En la sección del tutorial vamos a juntar todo esto a medida que creamos varias aplicaciones de ejemplo diferentes.