<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://github.com/felangel/bloc/actions"><img src="https://img.shields.io/github/workflow/status/felangel/bloc/build.svg?logo=github" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg" alt="Version"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg" alt="Installs"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg" alt="Ratings"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="http://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

## Introducción

Bloc extiende [VSCode](https://code.visualstudio.com/) con soporte para [la libería Bloc](https://bloclibrary.dev) y provee herramientas para crear [Blocs](https://github.com/felangel/bloc) y [Cubits](https://github.com/felangel/cubit) de manera efectiva tanto para aplicaciones desarrolladas en [Flutter](https://flutter.dev/) como [AngularDart](https://angulardart.dev/).

## Instalación

Bloc puede ser instalado desde la [tienda de VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) o [buscando dentro de VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Comandos

| Comando            | Descripción    |
| ------------------ | -------------- |
| `Bloc: New Bloc`   | Crea una Bloc  |
| `Cubit: New Cubit` | Crea una Cubit |

Puede activar el comando al abrir la paleta de comandos (View -> Command Palette) y ejecutar el comando.

![demostración](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

O puede hacer click derecho en el directorio en el cual desea crear el nuevo Bloc/Cubit y seleccionar el comando del menú desplegable.

![demostración](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Snippets

### Bloc

| Atajo                     | Descripción                                        |
| ------------------------- | -------------------------------------------------- |
| `bloc`                    | Crea una clase Bloc                                |
| `blocbuilder`             | Crea un Widget de clase BlocBuilder                |
| `bloclistener`            | Crea un Widget de clase BlocListener               |
| `multibloclistener`       | Crea un Widget de clase MultiBlocListener          |
| `blocconsumer`            | Crea un Widget de clase BlocConsumer               |
| `blocprovider`            | Crea un Widget de clase BlocProvider               |
| `multiblocprovider`       | Crea un Widget de clase MultiBlocProvider          |
| `repositoryprovider`      | Crea un Widget de clase RepositoryProvider         |
| `multirepositoryprovider` | Crea un Widget de clase MultiRepositoryProvider    |
| `blocdelegate`            | Crea un Widget de clase de tipo BlocDelegate       |
| `contextbloc`             | Atajo para `context.bloc<MyBloc>()`                |
| `blocof`                  | Atajo para `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Atajo para `context.repository<MyRepository>()`    |
| `repositoryof`            | Atajo para `RepositoryProvider.of<MyRepository>()` |

### Cubit

| Atajo                | Descripción                                |
| -------------------- | ------------------------------------------ |
| `cubit`              | Crea una clase Cubit                       |
| `cubitbuilder`       | Crea un Widget de clase CubitBuilder       |
| `cubitlistener`      | Crea un Widget de clase CubitListener      |
| `multicubitlistener` | Crea un Widget de clase MultiCubitListener |
| `cubitconsumer`      | Crea un Widget de clase CubitConsumer      |
| `cubitprovider`      | Crea un Widget de clase CubitProvider      |
| `multicubitprovider` | Crea un Widget de clase MultiCubitProvider |
| `contextcubit`       | Atajo para `context.cubit<MyCubit>()`      |
| `cubitof`            | Atajo para `CubitProvider.of<MyCubit>()`   |
