# Tutorial Clima Flutter

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo de Clima em Flutter que demonstre como gerenciar vários blocs para implementar temas dinâmicos, pull-to-refresh e muito mais. Nosso aplicativo meteorológico extrai dados reais de uma API e demonstra como separar nosso aplicativo em três camadas (dados, lógica de negócios e apresentação).

![demo](../assets/gifs/flutter_weather.gif)

## Setup

Vamos começar criando um novo projeto Flutter

[script](../_snippets/flutter_weather_tutorial/flutter_create.sh.md ':include')

Podemos então avançar e substituir o conteúdo de pubspec.yaml por

[pubspec.yaml](../_snippets/flutter_weather_tutorial/pubspec.yaml.md ':include')

?> **Nota:** Vamos adicionar alguns assets (ícones para tipos de clima) em nosso aplicativo, portanto, precisamos incluir a pasta de ativos no pubspec.yaml. Por favor, vá em frente e crie uma pasta _assets_ na raiz do projeto.

e instale todas as nossas dependências

[script](../_snippets/flutter_weather_tutorial/flutter_packages_get.sh.md ':include')

## REST API

Para esta aplicação, estaremos atingindo o [metaweather API](https://www.metaweather.com).

Vamos nos concentrar em dois pontos de extremidade:

- `/api/location/search/?query=$city` para obter um locationId para um determinado nome de cidade
- `/api/location/$locationId` para obter o clima para um determinado locationId

Abra [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) no seu navegador e você verá a seguinte resposta

[london_search.json](../_snippets/flutter_weather_tutorial/location_search.json.md ':include')

Podemos então obter o ID da localização na terra (woeid) e usá-lo para acessar a API do local.

Navegue para [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) no seu navegador e você verá a resposta para o clima em Londres. Deve ser algo como isto:

[london.json](../_snippets/flutter_weather_tutorial/location.json.md ':include')

Ótimo, agora que sabemos como serão os nossos dados, vamos criar os modelos de dados necessários.

## Criando Nosso Modelo de dados Climáticos

Embora a API do clima retorne o clima por vários dias, por simplicidade, vamos nos preocupar apenas com o clima de hoje.

Vamos começar criando uma pasta para os nossos modelos `lib/models` e criando um arquivo chamado `weather.dart` que conterá nosso modelo de dados para a classe `Weather`. Em seguida, dentro do `lib/models`, crie um arquivo chamado `models.dart`, que é o nosso arquivo barrel de onde exportamos todos os modelos.

#### Imports

Primeiro, precisamos importar nossas dependências para a nossa classe. No topo do `weather.dart`, vá em frente e adicione:

[weather.dart](../_snippets/flutter_weather_tutorial/equatable_import.dart.md ':include')

- `equatable`: Pacote que permite comparações entre objetos sem precisar substituir o operador `==`

#### Crie Enum WeatherCondition

Em seguida, criaremos um enumerador para todas as possíveis condições climáticas. Na próxima linha, vamos adicionar a enumeração.

_Estas condições provêm da definição do [metaweather API](https://www.metaweather.com/api/)_

[weather.dart](../_snippets/flutter_weather_tutorial/weather_condition.dart.md ':include')

#### Crie Modelo Weather

Em seguida, precisamos criar uma classe para ser nosso modelo de dados definido para o objeto climático retornado da API. Vamos extrair um subconjunto dos dados da API e criar um modelo `Weather`. Vá em frente e adicione-o ao arquivo `weather.dart` abaixo da enumeração `WeatherCondition`.

[weather.dart](../_snippets/flutter_weather_tutorial/weather.dart.md ':include')

?> Nós estendemos [`Equatable`](https://pub.dev/packages/equatable) para que possamos comparar instâncias do `Weather`. Por padrão, o operador de igualdade retorna true se e somente se este e outro forem a mesma instância.

Não há muita coisa acontecendo aqui; estamos apenas definindo nosso modelo de dados `Weather` e implementando um método `fromJson` para que possamos criar uma instância `Weather` a partir do corpo de resposta da API e criando um método que mapeie a cadeia bruta para uma `WeatherCondition` em nossa enumeração.

#### Exporte no arquivo Barrel

Agora precisamos exportar essa classe em nosso arquivo barrel. Abra `lib/models/models.dart` e adicione a seguinte linha de código:

[models.dart](../_snippets/flutter_weather_tutorial/weather_export.dart.md ':include')

## Provedor de Dados

Em seguida, precisamos criar nosso `WeatherApiClient`, que será responsável por fazer solicitações http para a API do tempo.

> O `WeatherApiClient` é a camada mais baixa da nossa arquitetura de aplicativos (o provedor de dados). A única responsabilidade é buscar dados diretamente da nossa API.

Como mencionamos anteriormente, buscaremos dois pontos endpoints, portanto nosso `WeatherApiClient` precisa expor dois métodos públicos:

- `getLocationId(String city)`
- `fetchWeather(int locationId)`

#### Criando nosso API Client do Clima

Essa camada do nosso aplicativo é chamada de camada de repositório, então vamos em frente e crie uma pasta para nossos repositórios. Dentro de `lib/`, crie uma pasta chamada `repositóries` e, em seguida, crie um arquivo chamado `weather_api_client.dart`.

#### Adicionando a Barrel

Assim como fizemos com nossos modelos, vamos criar um arquivo barrel para nossos repositórios. Dentro do `lib/repositories` vá em frente e adicione um arquivo chamado `repositories.dart` e deixe em branco por enquanto.

- `models`: Por fim, importamos o modelo `Weather` que criamos anteriormente.

#### Crie nossa classe WeatherApiClient

Vamos criar uma classe. Vá em frente e adicione isto:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/weather_api_client_constructor.dart.md ':include')

Aqui, estamos criando uma constante para nossa URL base e instanciando nosso cliente http. Em seguida, estamos criando nosso Construtor e exigindo que injetemos uma instância do httpClient. Você verá algumas dependências ausentes. Vamos em frente adicioná-las ao topo do arquivo:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/weather_api_client_imports.dart.md ':include')

- `meta`: define anotações que podem ser usadas pelas ferramentas fornecidas com o Dart SDK.
- `http`: Uma biblioteca composível baseada em Future para fazer solicitações HTTP.

#### Adicionar método getLocationId

Agora vamos adicionar nosso primeiro método público, que obterá o locationId para uma determinada cidade. Abaixo do construtor, vá em frente e adicione:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/get_location_id.dart.md ':include')

Aqui, estamos apenas fazendo uma solicitação HTTP simples e decodificando a resposta como uma lista. Falando em decodificação, você verá que `jsonDecode` é uma função de uma dependência que precisamos importar. Então, vamos em frente e faça isso agora. No topo do arquivo pelas outras importações, vá em frente e adicione:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/dart_convert_import.dart.md ':include')

- `dart:convert`: Codificador/decodificador para converter entre diferentes representações de dados, incluindo JSON e UTF-8.

#### Adicionar método fetchWeather

Em seguida, vamos adicionar nosso outro método para acessar a API metaweather. Este irá obter o clima para uma cidade, devido à sua localização. Abaixo do método `getLocationId` que acabamos de implementar, vamos em frente e adicione isso:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/fetch_weather.dart.md ':include')

Aqui, novamente, estamos apenas fazendo uma solicitação HTTP simples e decodificando a resposta em JSON. Você notará que novamente precisamos importar uma dependência, desta vez nosso modelo `Weather`. Na parte superior do arquivo, vá em frente e importe-o da seguinte maneira:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/models_import.dart.md ':include')

#### Exporte WeatherApiClient

Agora que criamos nossa classe com nossos dois métodos, vamos em frente e exportamos para o arquivo barrel. Dentro de `repositories.dart` vá em frente e adicione:

[repositories.dart](../_snippets/flutter_weather_tutorial/weather_api_client_export.dart.md ':include')

#### Qual o próximo

Concluímos nosso `DataProvider`, então é hora de passar para a próxima camada da arquitetura do nosso aplicativo: a **camada de repositório**.

## Repositório

> O `WeatherRepository` serve como uma abstração entre o código do cliente e o provedor de dados, para que, como desenvolvedor trabalhando em recursos, você não precise saber de onde vêm os dados. Nosso `WeatherRepository` dependerá do `WeatherApiClient` que acabamos de criar e exporá um único método público chamado, você adivinhou, `getWeather(String city)`. Ninguém precisa saber que, sob o capô, precisamos fazer duas chamadas de API (uma para locationId e outra para clima) porque ninguém realmente se importa. Só nos preocupamos em obter o `Clima 'para uma determinada cidade.

#### Criando nosso  Repositório Weather

Este arquivo pode estar em nossa pasta de repositório. Então vá em frente e crie um arquivo chamado `weather_repository.dart` e abra-o.

Nosso `WeatherRepository` é bastante simples e deve ser algo como isto:

[weather_repository.dart](../_snippets/flutter_weather_tutorial/weather_repository.dart.md ':include')

#### Exporte WeatherRepository no Barrel

Vá em frente e abra `repositories.dart` e exporte da seguinte maneira:

[repositories.dart](../_snippets/flutter_weather_tutorial/weather_repository_export.dart.md ':include')

Impressionante! Agora estamos prontos para avançar para a camada de lógica de negócios e começar a construir nosso `WeatherBloc`.

## Lógica de Negócio (Bloc)

> Nosso `WeatherBloc` é responsável por receber o `WeatherEvents` e convertê-los em `WeatherStates`. Depende do `WeatherRepository` para que possa recuperar o `Weather` quando um usuário inserir uma cidade de sua escolha.

#### Criando nosso primeiro Bloc

Vamos criar alguns blocs durante este tutorial, então vamos criar uma pasta dentro do `lib` chamada` blocs`. Novamente, como teremos vários blocs, vamos primeiro criar um arquivo barrel chamado `blocs.dart` dentro da pasta` blocs`.

Antes de pular para o bloc, precisamos definir quais eventos o nosso `WeatherBloc` manipulará e como vamos representar o nosso `WeatherState`. Para manter nossos arquivos pequenos, separaremos `event`, `state` e `bloc` em três arquivos.

#### Weather Event

Vamos criar um arquivo chamado `weather_event.dart` dentro da pasta `blocs`. Para simplificar, vamos começar com um único evento chamado `WeatherRequested`.

Podemos defini-lo como:

[weather_event.dart](../_snippets/flutter_weather_tutorial/fetch_weather_event.dart.md ':include')

Sempre que um usuário digitar uma cidade, adicionaremos um evento `WeatherRequested` à cidade especificada e nosso bloc será responsável por descobrir o que o tempo está aí e retornar um novo `WeatherState`.

Então vamos exportar a classe em nosso arquivo barrel. Dentro do `blocs.dart`, adicione:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_event_export.dart.md ':include')

#### Weather State

Em seguida, vamos criar nosso arquivo `state`. Dentro da pasta `blocs`, vá em frente e crie um arquivo chamado `weather_state.dart` onde nosso `weatherState` viverá.

Para a aplicação atual, teremos 4 estados possíveis:

- `WeatherInitial` - nosso estado inicial que não terá dados climáticos porque o usuário ainda não selecionou uma cidade
- `WeatherLoadInProgress` - um estado que ocorrerá enquanto buscamos o clima para uma determinada cidade
- `WeatherLoadSuccess` - um estado que ocorrerá se conseguirmos obter o tempo com êxito em uma determinada cidade.
- `WeatherLoadFailure` - um estado que ocorrerá se não conseguirmos obter tempo para uma determinada cidade.

Podemos representar esses estados da seguinte maneira:

[weather_state.dart](../_snippets/flutter_weather_tutorial/weather_state.dart.md ':include')

Então vamos exportar essa classe em nosso arquivo barrel. Dentro do `blocs.dart` vá em frente e adicione:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_state_export.dart.md ':include')

Agora que temos nossos `Eventos` e nossos `Estados` definidos e implementados, estamos prontos para fazer nosso `WeatherBloc`.

#### Weather Bloc

> Nosso `WeatherBloc` é muito direto. Para recapitular, ele converte `WeatherEvents` em `WeatherStates` e depende do `WeatherRepository`.

?> **Dica:** Confira a extensão [Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) para aproveitar os snippets de bloc e melhorar ainda mais sua eficiência e velocidade de desenvolvimento.

Vá em frente e crie um arquivo dentro da pasta `blocs` chamada `weather_bloc.dart` e adicione o seguinte:

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/weather_bloc.dart.md ':include')

Definimos nosso `initialState` como `WeatherInitial`, pois inicialmente o usuário não selecionou uma cidade. Então, tudo o que resta é implementar o `mapEventToState`.

Como estamos lidando apenas com o evento `WeatherRequested`, tudo o que precisamos fazer é `renderizar` nosso estado `WeatherLoadInProgress` quando obtivermos um evento `WeatherRequested` e, em seguida, tentar obter o clima no `WeatherRepository`.

Se conseguirmos recuperar o clima com sucesso, "produziremos" um estado "WeatherLoadSuccess" e se não for possível recuperar o clima, "produziremos" um estado "WeatherLoadFailure".

Agora exporte esta classe em `blocs.dart`:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_bloc_export.dart.md ':include')

Isso é tudo! Agora estamos prontos para avançar para a camada final: a camada de apresentação.

## Apresentação

### Setup

Como você provavelmente já viu em outros tutoriais, criaremos um `SimpleBlocDelegate` para que possamos ver todas as transições de estado em nosso aplicativo. Vamos em frente e crie `simple_bloc_delegate.dart` e crie nosso próprio delegado personalizado.

[simple_bloc_delegate.dart](../_snippets/flutter_weather_tutorial/simple_bloc_delegate.dart.md ':include')

Podemos então importá-lo para o arquivo `main.dart` e definir nosso delegate da seguinte forma:

[main.dart](../_snippets/flutter_weather_tutorial/main1.dart.md ':include')

Por fim, precisamos criar nosso `WeatherRepository` e injetá-lo no nosso widget `App` (que criaremos na próxima etapa).

[main.dart](../_snippets/flutter_weather_tutorial/main2.dart.md ':include')

### App Widget

Nosso widget `App` começará como um `StatelessWidget`, que tem o `WeatherRepository` injetado e cria o `MaterialApp` com o nosso widget `Weather` (que criaremos na próxima etapa). Estamos usando o widget `BlocProvider` para criar uma instância do nosso` WeatherBloc` e disponibilizá-lo para o widget `Weather` e seus filhos. Além disso, o `BlocProvider` gerencia a construção e o fechamento do `WeatherBloc`.

[main.dart](../_snippets/flutter_weather_tutorial/app.dart.md ':include')

### Weather

Agora precisamos criar nosso widget `Weather`. Vá em frente e crie uma pasta chamada `widgets` dentro de `lib` e crie um arquivo barrel dentro chamado `widgets.dart`. Em seguida, crie um arquivo chamado `weather.dart`.

> Nosso widget do tempo será um `StatelessWidget` responsável por renderizar os vários dados meteorológicos do tempo.

#### Criando nosso Stateless Widget

[weather.dart](../_snippets/flutter_weather_tutorial/weather_widget.dart.md ':include')

Tudo o que está acontecendo neste widget é que estamos usando o `BlocBuilder` com o nosso `WeatherBloc` para reconstruir nossa interface do usuário com base nas alterações de estado no nosso `WeatherBloc`.

Vá em frente e exporte `Weather` no arquivo `widgets.dart`.

Você notará que estamos referenciando um widget `CitySelection`,` Location`, `LastUpdated` e `CombinedWeatherTemperature`, que criaremos nas seções a seguir.

### Location Widget

Vá em frente e crie um arquivo chamado `location.dart` dentro da pasta` widgets`.

> Nosso widget `Location` é simples; exibe a localização atual.

[location.dart](../_snippets/flutter_weather_tutorial/location.dart.md ':include')

Certifique-se de exportar isso no arquivo `widgets.dart`.

### Ultima atualização

Em seguida, crie um arquivo `last_updated.dart` dentro da pasta `widgets`.

> Nosso widget `LastUpdated` também é super simples; exibe a última hora atualizada para que os usuários saibam o quão atualizados são os dados meteorológicos.

[last_updated.dart](../_snippets/flutter_weather_tutorial/last_updated.dart.md ':include')

Certifique-se de exportar isso no arquivo `widgets.dart`.

?> **Nota:** Estamos utilizando [`TimeOfDay`](https://api.flutter.dev/flutter/material/TimeOfDay-class.html) para formatar o `DateTime` em um formato mais legível por humanos.

### Combined Weather Temperature

Em seguida, crie um arquivo `combinado_tempo_temperatura.dart` dentro da pasta `widgets`.

> O widget `CombinedWeatherTemperature` é um widget de composição que exibe o clima atual junto com a temperatura. Ainda vamos modularizar os widgets `Temperature` e `WeatherConditions` para que todos possam ser reutilizados.

[combined_weather_temperature.dart](../_snippets/flutter_weather_tutorial/combined_weather_temperature.dart.md ':include')

Certifique-se de exportar isso no arquivo `widgets.dart`.

?> **Nota:** Estamos usando dois widgets não implementados: `WeatherConditions` e `Temperature`, que criaremos a seguir.

### Weather Conditions

Em seguida, crie um arquivo `weather_conditions.dart` dentro da pasta `widgets`.

> Nosso widget `WeatherConditions` será responsável por exibir as condições climáticas atuais (céu limpo, aguaceiros, trovoadas, etc.) juntamente com um ícone correspondente.

[weather_conditions.dart](../_snippets/flutter_weather_tutorial/weather_conditions.dart.md ':include')

Aqui você pode ver que estamos usando alguns assets. Faça o download deles em [aqui](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/assets) e adicione-os ao diretório `assets/` que criamos no início do projeto.

Certifique-se de exportar isso no arquivo `widgets.dart`.

?> **Dica:** Veja [icons8](https://icons8.com/icon/set/weather/office) para os ativos usados ​​neste tutorial.

### Temperatura

Em seguida, crie um arquivo `temperature.dart` dentro da pasta` widgets`.

> Nosso widget `Temperature` será responsável por exibir as temperaturas média, mínima e máxima.

[temperature.dart](../_snippets/flutter_weather_tutorial/temperature.dart.md ':include')

Certifique-se de exportar isso no arquivo `widgets.dart`.

### Seleção de Cidade

A última coisa que precisamos implementar para ter um aplicativo funcional é o widget `CitySelection`, que permite aos usuários digitar o nome de uma cidade. Vá em frente e crie um arquivo `city_selection.dart` dentro da pasta `widgets`.

> O widget `CitySelection` permitirá que os usuários insiram um nome de cidade e passem a cidade selecionada de volta para o widget `App`.

[city_selection.dart](../_snippets/flutter_weather_tutorial/city_selection.dart.md ':include')

Ele precisa ser um `StatefulWidget` porque precisa manter um `TextController`.

?> **Nota:** Quando pressionamos o botão de busca, usamos o `Navigator.pop` e passamos o texto atual do nosso `TextController` de volta à visualização anterior.

Certifique-se de exportar isso no arquivo `widgets.dart`.

## Rode o App

Agora que criamos todos os nossos widgets, vamos voltar ao arquivo `main.dart`. Você verá que precisamos importar o widget `Weather`, então vá em frente e adicione esta linha no topo.

[main.dart](../_snippets/flutter_weather_tutorial/widgets_import.dart.md ':include')

Em seguida, você pode executar o aplicativo com `flutter run` no terminal. Vá em frente e selecione uma cidade e você perceberá que ela tem alguns problemas:

- O fundo é branco e o texto também fica dificultando a leitura
- Não temos como atualizar os dados climáticos depois que eles são buscados
- A interface do usuário é muito simples
- Tudo está em graus Celsius e não temos como mudar as unidades

Vamos resolver esses problemas e levar nosso aplicativo Weather para o próximo nível!

## Pull-To-Refresh

> Para oferecer suporte ao pull-to-refresh, precisamos atualizar nosso `WeatherEvent` para lidar com um segundo evento:` WeatherRefreshRequested`. Vá em frente e adicione o seguinte código ao `blocs / weather_event.dart`

[weather_event.dart](../_snippets/flutter_weather_tutorial/refresh_weather_event.dart.md ':include')

Em seguida, precisamos atualizar nosso `mapEventToState` dentro de `weather_bloc.dart` para manipular um evento `WeatherRefreshRequested`. Vá em frente e adicione esta declaração `if` abaixo da existente.

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/refresh_weather_bloc.dart.md ':include')

Aqui, estamos apenas criando um novo evento que solicitará ao weatherRepository que faça uma chamada de API para obter o clima da cidade.

Podemos refatorar o `mapEventToState` para usar algumas funções auxiliares particulares, a fim de manter o código organizado e fácil de seguir:

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/map_event_to_state_refactor.dart.md ':include')

Por fim, precisamos atualizar nossa camada de apresentação para usar um widget `RefreshIndicator`. Vamos em frente e modifique nosso widget `Weather` em` widgets / weather.dart`. Existem algumas coisas que precisamos fazer.

- Importe `async` para o arquivo `weather.dart` para lidar com `Future`

[weather.dart](../_snippets/flutter_weather_tutorial/dart_async_import.dart.md ':include')

- Adicione um Completer

[weather.dart](../_snippets/flutter_weather_tutorial/add_completer.dart.md ':include')

Como nosso widget `Weather` precisará manter uma instância de um `Completer`, precisamos refatorá-lo para ser um `StatefulWidget`. Então, podemos inicializar o `Completer` em` initState`.

- Dentro do método `build` dos widgets, vamos agrupar o `ListView` em um widget `RefreshIndicator` dessa maneira. Em seguida, retorne o `_refreshCompleter.future;` quando o retorno de chamada `onRefresh` acontecer.

[weather.dart](../_snippets/flutter_weather_tutorial/refresh_indicator.dart.md ':include')

Para usar o `RefreshIndicator`, tivemos que criar um [`Completer`](https://api.dart.dev/stable/dart-async/Completer-class.html) o que nos permite produzir um "Future" que possamos concluir posteriormente.

A última coisa que precisamos fazer é concluir o `Completer` quando recebermos um estado` WeatherLoadSuccess` para descartar o indicador de carregamento assim que o clima for atualizado.

[weather.dart](../_snippets/flutter_weather_tutorial/bloc_consumer_refactor.dart.md ':include')

Convertemos nosso `BlocBuilder` em um `BlocConsumer` porque precisamos lidar com a reconstrução da interface do usuário com base em alterações de estado e também com efeitos colaterais (completando o `Completer`).

?> **Nota:** `BlocConsumer` é o mesmo que ter um` BlocBuilder` aninhado dentro de um `BlocListener`.

É isso aí! Agora resolvemos o problema nº 1 e os usuários podem atualizar o clima puxando para baixo. Sinta-se à vontade para executar o `flutter run` novamente e tente atualizar o clima.

Em seguida, vamos abordar a interface simples, criando um `ThemeBloc`.

## Temas Dinâmicos

> Nosso `ThemeBloc` será responsável por converter o `ThemeEvents` em `ThemeStates`.

Nossos `ThemeEvents` consistirão em um único evento chamado `WeatherChanged` que será adicionado sempre que as condições climáticas que estamos exibindo mudarem.

[theme_event.dart](../_snippets/flutter_weather_tutorial/weather_changed_event.dart.md ':include')

Nosso `ThemeState` consistirá em um` ThemeData` e um `MaterialColor` que usaremos para aprimorar nossa interface do usuário.

[theme_state.dart](../_snippets/flutter_weather_tutorial/theme_state.dart.md ':include')

Agora, podemos implementar nosso `ThemeBloc`, que deve se parecer com:

[theme_bloc.dart](../_snippets/flutter_weather_tutorial/theme_bloc.dart.md ':include')

Embora seja muito código, a única coisa aqui é a lógica para converter uma `WeatherCondition` em um novo `ThemeState`.

Agora podemos atualizar nosso `main` e um `ThemeBloc` fornecendo-o ao nosso `App`.

[main.dart](../_snippets/flutter_weather_tutorial/main3.dart.md ':include')

Nosso widget `App` pode então usar o BlocBuilder para reagir às alterações no `ThemeState`.

[app.dart](../_snippets/flutter_weather_tutorial/app2.dart.md ':include')

?> **Nota:** Estamos usando o `BlocProvider` para tornar nosso `ThemeBloc` disponível globalmente usando o `BlocProvider.of<ThemeBloc>(context)`.

A última coisa que precisamos fazer é criar um widget legal `GradientContainer` que colorirá nosso plano de fundo em relação às condições climáticas atuais.

[gradient_container.dart](../_snippets/flutter_weather_tutorial/gradient_container.dart.md ':include')

Agora podemos usar nosso `GradientContainer` no nosso widget `Weather` da seguinte forma:

[weather.dart](../_snippets/flutter_weather_tutorial/integrate_gradient_container.dart.md ':include')

Como queremos "fazer alguma coisa" em resposta a alterações de estado em nosso `WeatherBloc`, estamos usando o `BlocListener`. Neste caso, estamos concluindo e redefinindo o `Completer` e também adicionando o evento `WeatherChanged` ao `ThemeBloc`.

?> **Dica:** Veja [SnackBar Recipe](recipesfluttershowsnackbar.md) para obter mais informações sobre o widget `BlocListener`.

Estamos acessando nosso `ThemeBloc` via `BlocProvider.of<ThemeBloc>(context)` e, em seguida, adicionamos um evento `WeatherChanged` em cada `WeatherLoad`.

Também empacotamos nosso widget `GradientContainer` com um `BlocBuilder` de `ThemeBloc` para que possamos reconstruir o `GradientContainer` e seus filhos em resposta às alterações do `ThemeState`.

Impressionante! Agora, temos um aplicativo que parece muito melhor (na minha opinião :P) e resolvemos o problema nº 2.

Tudo o que resta é lidar com a conversão de unidades entre Celsius e Fahrenheit. Para isso, criaremos um widget `Settings` e um `SettingsBloc`.

## Conversão de Unidades

Começaremos criando nosso `SettingsBloc`, que converterá `SettingsEvents` em `SettingsStates`.

Nosso `SettingsEvents` consistirá em um único evento: `TemperatureUnitsToggled`.

[settings_event.dart](../_snippets/flutter_weather_tutorial/settings_event.dart.md ':include')

Nosso `SettingsState` consistirá simplesmente no atual `TemperatureUnits`.

[settings_state.dart](../_snippets/flutter_weather_tutorial/settings_state.dart.md ':include')

Por fim, precisamos criar nosso `SettingsBloc`:

[settings_bloc.dart](../_snippets/flutter_weather_tutorial/settings_bloc.dart.md ':include')

Tudo o que estamos fazendo é usar `fahrenheit` se `TemperatureUnitsToggled` for adicionado e as unidades atuais forem `celsius` e vice-versa.

Agora precisamos fornecer nosso `SettingsBloc` ao nosso widget `App` no `main.dart`.

[main.dart](../_snippets/flutter_weather_tutorial/main4.dart.md ':include')

Novamente, estamos tornando o `SettingsBloc` acessível globalmente usando o `BlocProvider` e também o fechando no retorno de chamada `close`. Desta vez, no entanto, como estamos expondo mais de um bloc usando o `BlocProvider` no mesmo nível, podemos eliminar alguns aninhamentos usando o widget `MultiBlocProvider`.

Agora precisamos criar nosso widget `Configurações` a partir do qual os usuários podem alternar as unidades.

[settings.dart](../_snippets/flutter_weather_tutorial/settings.dart.md ':include')

Estamos usando o `BlocProvider` para acessar o `SettingsBloc` através do `BuildContext` e, em seguida, o` BlocBuilder` para reconstruir nossa interface do usuário com base no `SettingsState` alterado.

Nossa interface do usuário consiste em um `ListView` com um único `ListTile` que contém um `Switch` que os usuários podem alternar para selecionar graus Celsius x Fahrenheit.

?> **Nota:** No método `onChanged` do switch, adicionamos um evento `TemperatureUnitsToggled` para notificar o `SettingsBloc` de que as unidades de temperatura foram alteradas.

Em seguida, precisamos permitir que os usuários acessem o widget `Settings` no nosso widget `Clima`.

Podemos fazer isso adicionando um novo `IconButton` no nosso `AppBar`.

[weather.dart](../_snippets/flutter_weather_tutorial/settings_button.dart.md ':include')

Estamos quase terminando! Nós apenas precisamos atualizar nosso widget `Temperature` para responder às unidades atuais.

[temperature.dart](../_snippets/flutter_weather_tutorial/update_temperature.dart.md ':include')

E, finalmente, precisamos injetar o `TemperatureUnits` no widget `Temperature`.

[consolidated_weather_temperature.dart](../_snippets/flutter_weather_tutorial/inject_temperature_units.dart.md ':include')

Isso é tudo! Agora, implementamos com sucesso um aplicativo meteorológico no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito nossa camada de apresentação de nossa lógica de negócios.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_weather).
