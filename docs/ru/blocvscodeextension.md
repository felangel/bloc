# Расширение Bloc для VSCode

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

## Введение

Блок расширяет [VSCode](https://code.visualstudio.com/) с поддержкой [Bloc](https://bloclibrary.dev) библиотеки и обеспечивает инструментарий для эффективного создания блоков для [Flutter](https://flutter.dev/) и [AngularDart](https://angulardart.dev/) приложений.

## Инсталляция

Блок можно установить из [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) или с помощью [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Новый блок

Команда `New Bloc` позволяет вам создать `Bloc` и `Events`/`States`, чтобы только осталось реализовать вашу логику в `mapEventToState`.

Вы можете активировать команду, запустив палитру команд (View -> Command Palette) и запустив `Bloc: New Bloc`.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Или вы можете щелкнуть правой кнопкой мыши на каталоге, в котором вы хотите создать блок и выбрать команду «Bloc: New Bloc» из контекстного меню.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Фрагменты

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
| `blocdelegate`            | Creates a BlocDelegate Class                         |
| `contextbloc`             | Shortcut for `context.bloc<MyBloc>()`                |
| `blocof`                  | Shortcut for `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Shortcut for `context.repository<MyRepository>()`    |
| `repositoryof`            | Shortcut for `RepositoryProvider.of<MyRepository>()` |
