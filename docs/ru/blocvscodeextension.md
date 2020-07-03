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

## Введение

Блок расширяет [VSCode](https://code.visualstudio.com/) с поддержкой [Bloc библиотеки](https://bloclibrary.dev) и обеспечивает инструментарий для эффективного создания блоков для [Flutter](https://flutter.dev/) и [AngularDart](https://angulardart.dev/) приложений.

## Инсталляция

Блок можно установить из [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) или с помощью [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## команды

| команда            | описание               |
| ------------------ | ---------------------- |
| `Bloc: New Bloc`   | Создать новый блок     |
| `Cubit: New Cubit` | Генерация нового кубит |

Вы можете активировать команду, запустив палитру команд (View -> Command Palette) и запустив команда.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Или вы можете щелкнуть правой кнопкой мыши на каталоге, в котором вы хотите создать блок/кубит и выбрать команду из контекстного меню.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Фрагменты

### Bloc

| Shortcut                  | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `bloc`                    | Creates a Bloc Class                                 |
| `blocbuilder`             | Creates a BlocBuilder Widget                         |
| `bloclistener`            | Creates a BlocListener Widget                        |
| `multibloclistener`       | Creates a MultiBlocListener Widget                   |
| `blocconsumer`            | Creates a BlocConsumer Widget                        |
| `blocprovider`            | Creates a BlocProvider Widget                        |
| `multiblocprovider`       | Creates a MultiBlocProvider Widget                   |
| `repositoryprovider`      | Creates a RepositoryProvider Widget                  |
| `multirepositoryprovider` | Creates a MultiRepositoryProvider Widget             |
| `blocobserver`            | Creates a BlocObserver Class                         |
| `contextbloc`             | Shortcut for `context.bloc<MyBloc>()`                |
| `blocof`                  | Shortcut for `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Shortcut for `context.repository<MyRepository>()`    |
| `repositoryof`            | Shortcut for `RepositoryProvider.of<MyRepository>()` |

### Cubit

| Shortcut             | Description                                |
| -------------------- | ------------------------------------------ |
| `cubit`              | Creates a Cubit Class                      |
| `cubitbuilder`       | Creates a CubitBuilder Widget              |
| `cubitlistener`      | Creates a CubitListener Widget             |
| `multicubitlistener` | Creates a MultiCubitListener Widget        |
| `cubitconsumer`      | Creates a CubitConsumer Widget             |
| `cubitprovider`      | Creates a CubitProvider Widget             |
| `multicubitprovider` | Creates a MultiCubitProvider Widget        |
| `contextcubit`       | Shortcut for `context.cubit<MyCubit>()`    |
| `cubitof`            | Shortcut for `CubitProvider.of<MyCubit>()` |
