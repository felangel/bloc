# ¿Por qué bloc?

> Bloc facilita la separación de la presentación de la lógica empresarial, haciendo que su código sea _rápido_, _fácil de testear_ y _reutilizable_.

Al crear aplicaciones de calidad en producción, la gestión de estado (state managment) se vuelve crítica.

Como desarrolladores queremos:

- saber en qué estado se encuentra nuestra aplicación en cualquier momento.
- testear fácilmente cada caso para asegurarse de que nuestra aplicación responda adecuadamente.
- registrar cada interacción del usuario en nuestra aplicación para que podamos tomar decisiones basadas en datos.
- trabajar de la manera más eficiente posible y reutilizar componentes tanto dentro de nuestra aplicación como en otras aplicaciones.
- tener muchos desarrolladores trabajando sin problemas dentro de una única base de código siguiendo los mismos patrones y convenciones.
- desarrollar aplicaciones rápidas y reactivas.

Bloc fue diseñado para satisfacer todas esas necesidades y muchas más.

Hay muchas soluciones de gestión de estado (state managment) y decidir cuál usar puede ser una tarea desalentadora.

Bloc fue diseñado con tres valores fundamentales en mente:

- Sencillo
  - Fácil de entender y puede ser utilizado por desarrolladores con diferentes niveles de habilidad.
- Poderoso
  - Ayuda a crear aplicaciones sorprendentes y complejas componiéndolas de componentes más pequeños.
- Testeable
  - Probar fácilmente todos los aspectos de una aplicación para que podamos iterar con confianza.

Bloc intenta hacer que los cambios de estado sean predecibles regulando cuándo puede ocurrir un cambio de estado y aplicando una única forma de cambiar el estado en toda una aplicación.