# Расширение Bloc для VSCode

[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)

[![Version](https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Install](https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Ratings](https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Flutter.io](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

## Введение

Блок расширяет [VSCode](https://code.visualstudio.com/) с поддержкой [Bloc](https://bloclibrary.dev) библиотеки и обеспечивает инструментарий для эффективного создания блоков для [Flutter](https://flutter.io/) и [AngularDart](https://webdev.dartlang.org) приложений.

## Инсталляция

Блок можно установить из [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) или с помощью [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Новый блок

Команда `New Bloc` позволяет вам создать `Bloc` и `Events`/`States`, чтобы только осталось реализовать вашу логику в `mapEventToState`.

Вы можете активировать команду, запустив палитру команд (View -> Command Palette) и запустив `Bloc: New Bloc`.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Или вы можете щелкнуть правой кнопкой мыши на каталоге, в котором вы хотите создать блок и выбрать команду «Bloc: New Bloc» из контекстного меню.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Фрагменты

### Блок

В файле `.dart` активируйте фрагмент, набрав `bloc` и нажав Enter. Затем вы можете назвать класс блока и заполнить сигнатуру и детали реализации с помощью табуляции.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/bloc-snippet-usage.gif)

### События

В файле `.dart` активируйте фрагмент, набрав `blocevent` и нажав Enter. Затем вы можете назвать класс события и ввести сигнатуру и детали реализации, используя вкладки.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocevent-snippet-usage.gif)

### Состояния

В файле `.dart` активируйте фрагмент, набрав `blocstate` и нажав Enter. Затем вы можете назвать класс состояния и заполнить сигнатуру и детали реализации с помощью табуляции.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocstate-snippet-usage.gif)

### Строитель

В файле `.dart` активируйте фрагмент, набрав `blocbuilder` и нажав Enter. Затем вы можете заполнить детали реализации с помощью вкладок.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocbuilder-snippet-usage.gif)

### Слушатель

В файле `.dart` активируйте фрагмент, набрав `bloclistener` и нажав Enter. Затем вы можете заполнить детали реализации с помощью вкладок.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/bloclistener-snippet-usage.gif)

### Поставщик

В файле `.dart` активируйте фрагмент, набрав `blocprovider` и нажав Enter. Затем вы можете заполнить детали реализации с помощью вкладок.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocprovider-snippet-usage.gif)

### Строитель дерева

В файле `.dart` активируйте фрагмент, набрав `blocprovidertree` и нажав Enter. Затем вы можете заполнить детали реализации с помощью вкладок.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocprovidertree-snippet-usage.gif)

### Делегат

В файле `.dart` активируйте фрагмент, набрав `blocdelegate` и нажав Enter. Затем вы можете заполнить детали реализации с помощью вкладок.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocdelegate-snippet-usage.gif)
