# Flutter Weather Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In this tutorial, we're going to build a Weather app in Flutter which demonstrates how to manage multiple cubits to implement dynamic theming, pull-to-refresh, and much more. Our weather app will pull live weather data from the public OpenMeteo API and demonstrate how to separate our application into layers (data, repository, business logic, and presentation).

![demo](./assets/gifs/flutter_weather.gif)

## Project Requirements

Our app should let users
- Search for a city on a dedicated search page
- See a pleasant depiction of the weather data returned by [Open Meteo API](https://open-meteo.com)
- Change the units displayed (metric vs imperial)

Additionally,
- The theme of the application should reflect the weather for the chosen city
- Application state should persist across sessions: i.e., the app should remember its state after closing and reopening it (using [HydratedBloc](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc))

## Key Concepts

- Observe state changes with [BlocObserver](/coreconcepts?id=blocobserver)
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), Flutter widget that provides a bloc to its children
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), Flutter widget that handles building the widget in response to new states
- Prevent unnecessary rebuilds with [Equatable](/faqs?id=when-to-use-equatable)
- [RepositoryProvider](/flutterbloccoreconcepts?id=repositoryprovider), a Flutter widget that provides a repository to its children
- [BlocListener](/flutterbloccoreconcepts?id=bloclistener), a Flutter widget that invokes the listener code in response to state changes in the bloc
- [MultiBlocProvider](/flutterbloccoreconcepts?id=multiblocprovider), a Flutter widget that merges multiple BlocProvider widgets into one
- [BlocConsumer](/flutterbloccoreconcepts?id=blocconsumer), a Flutter widget that exposes a builder and listener in order to react to new states
- [HydratedBloc](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc) to manage and persist state

## Setup

To begin, create a new flutter project

[script](_snippets/flutter_weather_tutorial/flutter_create.sh.md ':include')

### Project Structure

> Our app will consist of isolated features in corresponding directories. This enables us to scale as the number of features increases and allows developers to work on different features in parallel.

Our app can be broken down into four main features: **search, settings, theme, weather**. Let's create those directories.

[script](_snippets/flutter_weather_tutorial/feature_tree.md ':include')

### Architecture

> Following the [bloc architecture](https://bloclibrary.dev/#/architecture) guidelines, our application will consist of several layers.

In this tutorial, here's what these layers will do:
- **Data**: retrieve raw weather data from the API
- **Repository**: abstract the data layer and expose domain models for the application to consume
- **Business Logic**: manage the state of each feature (unit information, city details, themes, etc.)
- **Presentation**: display weather information and collect input from users (settings page, search page etc.)

## Data Layer

For this application we'll be hitting the [Open Meteo API](https://open-meteo.com).

We'll be focusing on two endpoints:

- `https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1` to get a location for a given city name
- `https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true` to get the weather for a given location

Open [https://geocoding-api.open-meteo.com/v1/search?name=chicago&count=1](https://geocoding-api.open-meteo.com/v1/search?name=chicago&count=1) in your browser to see the response for the city of Chicago. We will use the `latitude` and `longitude` in the response to hit the weather endpoint.

The `latitude`/`longitutde` for Chicago is `41.85003`/`-87.65005`. Navigate to [https://api.open-meteo.com/v1/forecast?latitude=43.0389&longitude=-87.90647&current_weather=true](https://api.open-meteo.com/v1/forecast?latitude=43.0389&longitude=-87.90647&current_weather=true) in your browser and you'll see the response for weather in Chicago which contains all the data we will need for our app.

### OpenMeteo API Client

> The OpenMeteo API Client is independent of our application. As a result, we will create it as an internal package (and could even publish it on [pub.dev](https://pub.dev)). We can then use the package by adding it to the `pubspec.yaml` for the repository layer, which will handle data requests for our main weather application.

Create a new directory on the project level called `packages`. This directory will store all of our internal packages.

Within this directory, run the built-in `flutter create` command to create a new package called `open_meteo_api` for our API client.

[script](_snippets/flutter_weather_tutorial/data_layer/flutter_create_api_client.sh.md ':include')

### Weather Data Model

Next, let's create `location.dart` and `weather.dart` which will contain the models for the `location` and `weather` API endpoint responses.

[script](_snippets/flutter_weather_tutorial/data_layer/open_meteo_models_tree.md ':include')

#### Location Model

The `location.dart` model should store data returned by the location API, which looks like the following:

[location.json](_snippets/flutter_weather_tutorial/data_layer/location.json.md ':include')

Here's the in-progress `location.dart` file which stores the above response:

[location.dart](_snippets/flutter_weather_tutorial/data_layer/location.dart.md ':include')

#### Weather Model

Next, let's work on `weather.dart`. Our weather model should store data returned by the weather API, which looks like the following:

[weather.json](_snippets/flutter_weather_tutorial/data_layer/weather.json.md ':include')

Here's the in-progress `weather.dart` file which stores the above response:

[weather.dart](_snippets/flutter_weather_tutorial/data_layer/weather.dart.md ':include')

### Barrel Files

While we're here, let's quickly create a [barrel file](https://adrianfaciu.dev/posts/barrel-files/) to clean up some of our imports down the road.

Create a `models.dart` barrel file and export the two models:

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/lib/src/models/models.dart ':include')

Let's also create a package level barrel file, `open_meteo_api.dart`

[script](_snippets/flutter_weather_tutorial/data_layer/open_meteo_models_barrel_tree.md ':include')

In the top level, `open_meteo_api.dart` let's export the models:

[open_meteo_api.dart](_snippets/flutter_weather_tutorial/data_layer/export_top_level_models.dart.md ':include')

### Setup

> We need to be able to [serialize and deserialize](https://en.wikipedia.org/wiki/Serialization) our models in order to work with the API data. To do this, we will add `toJson` and `fromJson` methods to our models.

> Additionally, we need a way to [make HTTP network requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) to fetch data from an API. Fortunately, there are a number of popular packages for doing just that.

We will be using the [json_annotation](https://pub.dev/packages/json_annotation), [json_serializable](https://pub.dev/packages/json_serializable), and [build_runner](https://pub.dev/packages/build_runner) packages to generate the `toJson` and `fromJson` implementations for us.

In a later step, we will also use the [http](https://pub.dev/packages/http) package to send network requests to the MetaWeather API so our application can display the current weather data.

Let's add these dependencies to the `pubspec.yaml`.

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/pubspec.yaml ':include')

?> **Note**: Remember to run `flutter pub get` after adding the dependencies.

### (De)Serialization

In order for code generation to work, we need to annotate our code using the following:

- `@JsonSerializable` to label classes which can be serialized
- `@JsonKey` to provide string representations of field names
- `@JsonValue` to provide string representations of field values
- Implement `JSONConverter` to convert object representations into JSON representations

For each file we also need to:

- Import `json_annotation`
- Include the generated code using the [part](https://dart.dev/guides/libraries/create-library-packages#organizing-a-library-package) keyword
- Include `fromJson` methods for deserialization

#### Location Model

Here is our complete `location.dart` model file:

[location.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/lib/src/models/location.dart ':include')

#### Weather Model

Here is our complete `weather.dart` model file:

[weather.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/lib/src/models/weather.dart ':include')

#### Create Build File

In the `open_meteo_api` folder, create a `build.yaml` file. The purpose of this file is to handle discrepancies between naming conventions in the `json_serializable` field names.

[script](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/build.yaml ':include')

#### Code Generation

Let's use `build_runner` to generate the code.

[script](_snippets/flutter_weather_tutorial/build_runner_builder.sh.md ':include')

`build_runner` should generate the `location.g.dart` and `weather.g.dart` files.

### OpenMeteo API Client

Let's create our API client in `open_meteo_api_client.dart` within the `src` directory. Our project structure should now look like this:

[script](_snippets/flutter_weather_tutorial/data_layer/open_meteo_api_client_tree.md ':include')

We can now use the [http](https://pub.dev/packages/http) package we added earlier to the `pubspec.yaml` file to make HTTP requests to the Metaweather API and use this information in our application.

Our API client will expose two methods:

- `locationSearch` which returns a `Future<Location>`
- `getWeather` which returns a `Future<Weather>`

#### Location Search

The `locationSearch` method hits the location API and throws `LocationRequestFailure` errors as applicable. The completed method looks as follows:

[open_meteo_api_client.dart](_snippets/flutter_weather_tutorial/data_layer/location_search_method.dart.md ':include')

#### Get Weather

Similarly, the `getWeather` method hits the weather API and throws `WeatherRequestFailure` errors as applicable. The completed method looks as follows:

[open_meteo_api_client.dart](_snippets/flutter_weather_tutorial/data_layer/get_weather_method.dart.md ':include')

The completed file looks like this:

[open_meteo_api_client.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/lib/src/open_meteo_api_client.dart ':include')

#### Barrel File Updates

Let's wrap up this package by adding our API client to the barrel file.

[open_meteo_api.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/lib/open_meteo_api.dart ':include')

### Unit Tests

> It's especially important to write unit tests for the data layer since it's the foundation of our application. Unit tests will give us confidence that the package behaves as expected.

#### Setup

Earlier, we added the [test](https://pub.dev/packages/test) package to our pubspec.yaml which allows to easily write unit tests.

We will be creating a test file for the api client as well as the two models.

#### Location Tests

[location_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/test/location_test.dart ':include')

#### Weather Tests

[weather_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/test/weather_test.dart ':include')

#### API Client Tests

Next, let's test our API client. We should test to ensure that our API client handles both API calls correctly, including edge cases.

?> **Note**: We don't want our tests to make real API calls since our goal is to test the API client logic (including all edge cases) and not the API itself. In order to have a consistent, controlled test environment, we will use [mocktail](https://github.com/felangel/mocktail) (which we added to the pubspec.yaml file earlier) to mock the `http` client.

[open_meteo_api_client_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/open_meteo_api/test/open_meteo_api_client_test.dart ':include')

#### Test Coverage

Finally, let's gather test coverage to verify that we've covered each line of code with at least one test case.

[script](_snippets/flutter_weather_tutorial/test_coverage.sh.md ':include')

## Repository Layer

> The goal of our repository layer is to abstract our data layer and facilitate communication with the bloc layer. In doing this, the rest of our code base depends only on functions exposed by our repository layer instead of specific data provider implementations. This allows us to change data providers without disrupting any of the application-level code. For example, if we decide to migrate away from metaweather, we should be able to create a new API client and swap it out without having to make changes to the public API of the repository or application layers.

### Setup

Inside the packages directory, run the following command:

[script](_snippets/flutter_weather_tutorial/repository_layer/flutter_create_repository.sh.md ':include')

We will use the same packages as in the `open_meteo_api` package including the `open_meteo_api` package from the last step. Update your `pubspec.yaml` and run `flutter packages get`.

?> **Note**: We're using a `path` to specify the location of the `open_meteo_api` which allows us to treat it just like an external package from `pub.dev`.

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/pubspec.yaml ':include')

### Weather Repository Models

> We will be creating a new `weather.dart` file to expose a domain-specific weather model. This model will contain only data relevant to our business cases -- in other words it should be completely decoupled from the API client and raw data format. As usual, we will also create a `models.dart` barrel file.

[script](_snippets/flutter_weather_tutorial/repository_layer/repository_models_barrel_tree.md ':include')

This time, our weather model will only store the `location, temperature, condition` properties. We will also continue to annotate our code to allow for serialization and deserialization.

[weather.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/lib/src/models/weather.dart ':include')

Update the barrel file we created previously to include the models.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/lib/src/models/models.dart ':include')

#### Create Build File

As before, we need to create a `build.yaml` file with the following contents:

[script](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/build.yaml ':include')

#### Code Generation

As we have done previously, run the following command to generate the (de)serialization implementation.

[script](_snippets/flutter_weather_tutorial/build_runner_builder.sh.md ':include')

#### Barrel File

Let's also create a package-level barrel file named `packages/weather_repository/lib/weather_repository.dart` to export our models:

[script](_snippets/flutter_weather_tutorial/repository_layer/export_top_level_models.dart.md ':include')

### Weather Repository

> The main goal of the `WeatherRepository` is to provide an interface which abstracts the data provider. In this case, the `WeatherRepository` will have a dependency on the `WeatherApiClient` and expose a single public method, `getWeather(String city)`.

?> **Note**: Consumers of the `WeatherRepository` are not privy to the underlying implementation details such as the fact that two network requests are made to the metaweather API. The goal of the `WeatherRepository` is to separate the "what" from the "how" -- in other words, we want to have a way to fetch weather for a given city, but don't care about how or where that data is coming from.

#### Setup

Let's create the `weather_repository.dart` file within the `src` directory of our package and work on the repository implementation.

The main method we will focus on is `getWeather(String city)`. We can implement it using two calls to the API client as follows:

[weather_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/lib/src/weather_repository.dart ':include')

#### Barrel File

Update the barrel file we created previously.

[weather_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/lib/weather_repository.dart ':include')

### Unit Tests

> Just as with the data layer, it's critical to test the repository layer in order to make sure the domain level logic is correct. To test our `WeatherRepository`, we will use the [mocktail](https://github.com/felangel/mocktail) library. We will mock the underlying api client in order to unit test the `WeatherRepository` logic in an isolated, controlled environment.

[weather_repository_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/packages/weather_repository/test/weather_repository_test.dart ':include')

## Business Logic Layer

> In the business logic layer, we will be consuming the weather domain model from the `WeatherRepository` and exposing a feature-level model which will be surfaced to the user via the UI.

?> **Note**: This is the third different type of weather model we're implementing. In the API client, our weather model contained all the info returned by the API. In the repository layer, our weather model contained only the abstracted model based on our business case. In this layer, our weather model will contain relevant information needed specifically for the current feature set.

### Setup

Because our business logic layer resides in our main app, we need to edit the `pubspec.yaml` for the entire `flutter_weather` project and include all the packages we'll be using.

- Using [equatable](https://pub.dev/packages/equatable) enables our app's state class instances to be compared using the equals `==` operator. Under the hood, bloc will compare our states to see if they're equal, and if they're not, it will trigger a rebuild. This guarantees that our widget tree will only rebuild when necessary to keep performance fast and responsive.
- We can spice up our user interface with [google_fonts](https://pub.dev/packages/google_fonts).
- [HydratedBloc](https://pub.dev/packages/hydrated_bloc) allows us to persist application state when the app is closed and reopened.
- We'll include the `weather_repository` package we just created to allow us to fetch the current weather data!

For testing, we'll want to include the usual `test` package, along with `mocktail` for mocking dependencies and [bloc_test](https://pub.dev/packages/bloc_test), to enable easy testing of business logic units, or blocs!

[pubspec.yaml.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/pubspec.yaml ':include')

Next, we will be working on the application layer within the `weather` feature directory.

### Weather Model

> The goal of our weather model is to keep track of weather data displayed by our app, as well as temperature settings (Celsius or Fahrenheit).

Create `flutter_weather/lib/weather/models/weather.dart`:

[weather.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/models/weather.dart ':include')

### Create Build File

Create a `build.yaml` file for the business logic layer.

[script](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/build.yaml ':include')

### Code Generation

Run `build_runner` to generate the (de)serialization implementations.

[script](_snippets/flutter_weather_tutorial/build_runner_builder.sh.md ':include')

### Barrel File

Let's export our models from the barrel file (flutter_weather/lib/weather/models/models.dart):

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/models/models.dart ':include')

### Weather

We will use `HydratedCubit` to enable our app to remember its application state, even after it's been closed and reopened.

?> **Note**: `HydratedCubit` is an extension of `Cubit` which handles persisting and restoring state across sessions.

#### Weather State

Using the [Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or [Bloc IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc) extension, right click on the `weather` directory and create a new cubit called `Weather`. The project structure should look like this:

[script](_snippets/flutter_weather_tutorial/business_logic_layer/weather_cubit_tree.md ':include')

There are four states our weather app can be in:

- `initial` before anything loads
- `loading` during the API call
- `success` if the API call is successful
- `failure` if the API call is unsuccessful

The `WeatherStatus` enum will represent the above.

The complete weather state should look like this:

[weather_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/cubit/weather_state.dart ':include')

#### Weather Cubit

Now that we've defined the `WeatherState`, let's write the `WeatherCubit` which will expose the following methods:

- `fetchWeather(String? city)` uses our weather repository to try and retrieve a weather object for the given city
- `refreshWeather()` retrieves a new weather object using the weather repository given the current weather state
- `toggleUnits()` toggles the state between Celsius and Fahrenheit
- `fromJson(Map<String, dynamic> json)`, `toJson(WeatherState state)` used for persistence

[weather_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/cubit/weather_cubit.dart ':include')

?> **Note**: Remember to generate the (de)serialization code via `flutter packages pub run build_runner build`

### Theme

Next, we'll implement the business logic for the dynamic theming.

#### Theme Cubit

Let's create a `ThemeCubit` to manage the theme of our app. The theme will change based on the current weather conditions.

[script](_snippets/flutter_weather_tutorial/business_logic_layer/theme_cubit_tree.md ':include')

We will expose an `updateTheme` method to update the theme depending on the weather condition.

[theme_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/theme/cubit/theme_cubit.dart ':include')

### Unit Tests

> Similar to the data and repository layers, it's critical to unit test the business logic layer to ensure that the feature-level logic behaves as we expect. We will be relying on the [bloc_test](https://pub.dev/packages/bloc_test) in addition to `mocktail` and `test`.

Let's add the `test`, `bloc_test`, and `mocktail` packages to the `dev_dependencies`.

[pubspec.yaml.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/pubspec.yaml ':include')

?> **Note**: The `bloc_test` package allows us to easily prepare our blocs for testing, handle state changes, and check results in a consistent way.

#### Theme Cubit Tests

[theme_cubit_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/test/theme/cubit/theme_cubit_test.dart ':include')

#### Weather Cubit Tests

[weather_cubit_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/test/weather/cubit/weather_cubit_test.dart ':include')

## Presentation Layer

### Weather Page

We will start with the `WeatherPage` which uses `BlocProvider` in order to provide an instance of the `WeatherCubit` to the widget tree.

[weather_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/view/weather_page.dart ':include')

You'll notice that page depends on `SettingsPage` and `SearchPage` widgets, which we will create next.

### SettingsPage

The settings page allows users to update their preferences for the temperature units.

[settings_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/settings/view/settings_page.dart ':include')

### SearchPage

The search page allows users to enter the name of their desired city and provides the search result to the previous route via `Navigator.of(context).pop`.

[search_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/search/view/search_page.dart ':include')

### Weather Widgets

The app will display different screens depending on the four possible states of the `WeatherCubit`.

#### WeatherEmpty

This screen will show when there is no data to display because the user has not yet selected a city.

[weather_empty.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/widgets/weather_empty.dart ':include')

#### WeatherError

This screen will display if there is an error.

[weather_error.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/widgets/weather_error.dart ':include')

#### WeatherLoading

This screen will display as the application fetches the data.

[weather_loading.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/widgets/weather_loading.dart ':include')

#### WeatherPopulated

This screen will display after the user has selected a city and we have retrieved the data.

[weather_populated.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/widgets/weather_populated.dart ':include')

### Barrel File

Let's add these states to a barrel file to clean up our imports.

[widgets.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/weather/widgets/widgets.dart ':include')

### Entrypoint

Our `main.dart` file should initialize our `WeatherApp` and `BlocObserver` (for debugging purposes), as well as setup our `HydratedStorage` to persist state across sessions.

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/main.dart ':include')

Our `app.dart` widget will handle building the `WeatherPage` view we previously created and use `BlocProvider` to inject our `ThemeCubit` which handles theme data.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/lib/app.dart ':include')

### Widget Tests

The `bloc_test` library also exposes `MockBlocs` and `MockCubits` which make it easy to test UI. We can mock the states of the various cubits and ensure that the UI reacts correctly.

[weather_page_test.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_weather/test/weather/view/weather_page_test.dart ':include')

?> **Note**: We're using a `MockWeatherCubit` together with the `when` API from `mocktail` in order to stub the state of the cubit in each of the test cases. This allows us to simulate all states and verify the UI behaves correctly under all circumstances.

## Summary

That's it, we have completed the tutorial! 🎉

We can run the final app using the `flutter run` command.

The full source code for this example, including unit and widget tests, can be found [here](https://github.com/felangel/bloc/tree/master/examples/flutter_weather).
