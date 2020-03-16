# Bloc Extension for VSCode

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

## Introdução

Plugin Bloc para [IntelliJ](https://www.jetbrains.com/idea/) e [Android Studio](https://developer.android.com/studio/) com suporte para o [Bloc](https://bloclibrary.dev) e provê ferramentas para criar Blocs eficientemente para apps [Flutter](https://flutter.dev/) e [AngularDart](https://angulardart.dev/).

## Instalação

Bloc pode ser instalado a partir de [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Novos comandos Bloc

O comando New Bloc permite criar um bloc e os eventos / estados para que tudo o que resta fazer seja implementar sua lógica no `mapEventToState`.

Você pode ativar o comando iniciando a paleta de comandos (Exibir -> Paleta de Comandos) e executando "Bloc: New Bloc".

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Ou você pode clicar com o botão direito do mouse no diretório em que deseja criar o bloc e selecionar o comando "Bloc: Novo bloc" no menu de contexto.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Snippets de Uso

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
