# Bloc Extension for VSCode

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

## Úvod

[VSCode](https://code.visualstudio.com/) rozšíření Blocu pro podporou knihovny [Bloc](https://bloclibrary.dev) a poskytování efektivních nástrojů pro efektivní vytváření Bloců jak ve [Flutter](https://flutter.io/), tak i [AngularDart](https://webdev.dartlang.org) aplikacích.

## Instalace

Bloc může být nainstalován z [VSCode obchodu](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) nebo [vyhledáním ve VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Jak používat příkaz New Bloc

Příkaz New Bloc umožňuje vytvořit Bloc a Události/Stavy tak, abyste museli doimplementovat pouze logiku v `mapEventToState`.

Můžete aktivovat příkaz spuštěním palety příkazů (View -> Command Palette) a spuštěním "Bloc: New Bloc".

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Nebo můžete kliknout pravým tlačítkem na složku, ve které chcete vytvořit bloc a vybrat příkaz "Bloc: New Bloc" z kontextové nabídky.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Jak používat úryvky

### Bloc

V `.dart` souboru aktivujete úryvky psaním `bloc` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/bloc-snippet-usage.gif)

### BlocEvent

V `.dart` souboru aktivujete úryvky psaním `blocevent` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocevent-snippet-usage.gif)

### BlocState

V `.dart` souboru aktivujete úryvky psaním `blocstate` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocstate-snippet-usage.gif)

### BlocBuilder

V `.dart` souboru aktivujete úryvky psaním `blocbuilder` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocbuilder-snippet-usage.gif)

### BlocListener

V `.dart` souboru aktivujete úryvky psaním `bloclistener` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/bloclistener-snippet-usage.gif)

### BlocProvider

V `.dart` souboru aktivujete úryvky psaním `blocprovider` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocprovider-snippet-usage.gif)

### BlocProviderTree

V `.dart` souboru aktivujete úryvky psaním `blocprovidertree` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocprovidertree-snippet-usage.gif)

### BlocDelegate

V `.dart` souboru aktivujete úryvky psaním `blocdelegate` a zmáčknutím enteru. Potom můžete pojmenovat bloc a doplnit implementační detaily tabováním.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/blocdelegate-snippet-usage.gif)
