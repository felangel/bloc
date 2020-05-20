# Extensiones de Bloc para VSCode

[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)

[![Version](https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Install](https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Ratings](https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Flutter Website](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

## Introducción

Bloc extiende [VSCode](https://code.visualstudio.com/) con soporte para la libería [Bloc](https://bloclibrary.dev) y provee herramientas para crear Blocs de manera efectiva tanto para aplicaciones desarrolladas en [Flutter](https://flutter.dev/) como [AngularDart](https://angulardart.dev/).

## Instalación

Bloc puede ser instalado desde la [tienda de VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) o [buscando dentro de VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Uso del Comando New Bloc

El comando `New Bloc` te permite crear un Bloc y los eventos/estados correspondientes de manera que solo reste la implementación de la lógica en la función `mapEventToState`.

Puede activar el comando al abrir la paleta de comandos (View -> Command Palette) y ejecutar `Bloc: New Bloc`.

![demostración](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

O puede hacer click derecho en el directorio en el cual desea crear el nuevo Bloc y seleccionar el comando `Block: New Bloc` del menú desplegable.

![demostración](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Uso de Snippets

| Atajo                     | Descripción                                           |
| ------------------------- | ----------------------------------------------------- |
| `bloc`                    | Crea una clase Bloc                                   |
| `blocbuilder`             | Crea un Widget de clase BlocBuilder                   |
| `bloclistener`            | Crea un Widget de clase BlocListener                  |
| `multibloclistener`       | Crea un Widget de clase MultiBlocListener             |
| `blocconsumer`            | Crea un Widget de clase BlocConsumer                  |
| `blocprovider`            | Crea un Widget de clase BlocProvider                  |
| `multiblocprovider`       | Crea un Widget de clase MultiBlocProvider             |
| `repositoryprovider`      | Crea un Widget de clase RepositoryProvider            |
| `multirepositoryprovider` | Crea un Widget de clase MultiRepositoryProvider       |
| `blocdelegate`            | Crea un Widget de clase de tipo BlocDelegate          |
| `contextbloc`             | Atajo para `context.bloc<MyBloc>()`                   |
| `blocof`                  | Atajo para `BlocProvider.of<MyBloc>()`                |
| `contextrepository`       | Atajo para `context.repository<MyRepository>()`       |
| `repositoryof`            | Atajo para `RepositoryProvider.of<MyRepository>()`    |
