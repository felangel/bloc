# Flutter Weather Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a Weather app in Flutter which demonstrates how to manage multiple blocs to implement dynamic theming, pull-to-refresh, and much more. Our weather app will pull real data from an API and demonstrate how to separate our application into three layers (data, business logic, and presentation).

![demo](./assets/gifs/flutter_weather.gif)

## Setup

We’ll start off by creating a brand new Flutter project

[script](_snippets/flutter_weather_tutorial/flutter_create.sh.md ':include')

We can then go ahead and replace the contents of pubspec.yaml with

[pubspec.yaml](_snippets/flutter_weather_tutorial/pubspec.yaml.md ':include')

?> **Note:** We are going to add some assets (icons for weather types) in our app, so we need to include the assets folder in the pubspec.yaml. Please go ahead and create an _assets_ folder in the root of the project.

and then install all of our dependencies

[script](_snippets/flutter_weather_tutorial/flutter_packages_get.sh.md ':include')

## REST API

For this application we'll be hitting the [metaweather API](https://www.metaweather.com).

We'll be focusing on two endpoints:

- `/api/location/search/?query=$city` to get a locationId for a given city name
- `/api/location/$locationId` to get the weather for a given locationId

Open [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) in your browser and you'll see the following response

[london_search.json](_snippets/flutter_weather_tutorial/location_search.json.md ':include')

We can then get the where-on-earth-id (woeid) and use it to hit the location api.

Navigate to [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) in your browser and you'll see the response for weather in London. It should look something like this:

[london.json](_snippets/flutter_weather_tutorial/location.json.md ':include')

Great, now that we know what our data is going to look like, let’s create the necessary data models.

## Creating Our Weather Data Model

Even though the weather API returns weather for multiple days, for simplicity, we're only going to worry about today's weather.

Let's start off by creating a folder for our models `lib/models` and create a file in there called `weather.dart` which will hold our data model for our `Weather` class. Next inside of `lib/models` create a file called `models.dart` which is our barrel file where we export all models from.

#### Imports

First off we need to import our dependencies for our class. At the top of `weather.dart` go ahead and add:

[weather.dart](_snippets/flutter_weather_tutorial/equatable_import.dart.md ':include')

- `equatable`: Package that allows comparisons between objects without having to override the `==` operator

#### Create WeatherCondition Enum

Next we are going to create an enumerator for all our possible weather conditions. On the next line, let's add the enum.

_These conditions come from the definition of the [metaweather API](https://www.metaweather.com/api/)_

[weather.dart](_snippets/flutter_weather_tutorial/weather_condition.dart.md ':include')

#### Create Weather Model

Next we need to create a class to be our defined data model for the weather object returned from the API. We are going to extract a subset of the data from the API and create a `Weather` model. Go ahead and add this to the `weather.dart` file below the `WeatherCondition` enum.

[weather.dart](_snippets/flutter_weather_tutorial/weather.dart.md ':include')

?> We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare `Weather` instances. By default, the equality operator returns true if and only if this and other are the same instance.

There's not much happening here; we are just defining our `Weather` data model and implementing a `fromJson` method so that we can create a `Weather` instance from the API response body and creating a method that maps the raw string to a `WeatherCondition` in our enum.

#### Export in Barrel

Now we need to export this class in our barrel file. Open up `lib/models/models.dart` and add the following line of code:

[models.dart](_snippets/flutter_weather_tutorial/weather_export.dart.md ':include')

## Data Provider

Next, we need to build our `WeatherApiClient` which will be responsible for making http requests to the weather API.

> The `WeatherApiClient` is the lowest layer in our application architecture (the data provider). It's only responsibility is to fetch data directly from our API.

As we mentioned earlier, we are going to be hitting two endpoints so our `WeatherApiClient` needs to expose two public methods:

- `getLocationId(String city)`
- `fetchWeather(int locationId)`

#### Creating our Weather API Client

This layer of our application is called the repository layer, so let's go ahead and create a folder for our repositories. Inside of `lib/` create a folder called `repositories` and then create a file called `weather_api_client.dart`.

#### Adding a Barrel

Same as we did with our models, let's create a barrel file for our repositories. Inside of `lib/repositories` go ahead and add a file called `repositories.dart` and leave it blank for now.

- `models`: Lastly, we import our `Weather` model we created earlier.

#### Create Our WeatherApiClient class

Let's create a class. Go ahead and add this:

[weather_api_client.dart](_snippets/flutter_weather_tutorial/weather_api_client_constructor.dart.md ':include')

Here we are creating a constant for our base URL and instantiating our http client. Then we are creating our Constructor and requiring that we inject an instance of httpClient. You'll see some missing dependencies. Let's go ahead and add them to the top of the file:

[weather_api_client.dart](_snippets/flutter_weather_tutorial/weather_api_client_imports.dart.md ':include')

- `meta`: Defines annotations that can be used by the tools that are shipped with the Dart SDK.
- `http`: A composable, Future-based library for making HTTP requests.

#### Add getLocationId Method

Now let's add our first public method, which will get the locationId for a given city. Below the constructor, go ahead and add:

[weather_api_client.dart](_snippets/flutter_weather_tutorial/get_location_id.dart.md ':include')

Here we are just making a simple HTTP request and then decoding the response as a list. Speaking of decoding, you'll see `jsonDecode` is a function from a dependency we need to import. So let's go ahead and do that now. At the top of the file by the other imports go ahead and add:

[weather_api_client.dart](_snippets/flutter_weather_tutorial/dart_convert_import.dart.md ':include')

- `dart:convert`: Encoder/Decoder for converting between different data representations, including JSON and UTF-8.

#### Add fetchWeather Method

Next up let's add our other method to hit the metaweather API. This one will get the weather for a city given it's locationId. Below the `getLocationId` method we just implemented, let's go ahead and add this:

[weather_api_client.dart](_snippets/flutter_weather_tutorial/fetch_weather.dart.md ':include')

Here again we are just making a simple HTTP request and decoding the response into JSON. You'll notice we again need to import a dependency, this time our `Weather` model. At the top of the file, go ahead and import it like so:

[weather_api_client.dart](_snippets/flutter_weather_tutorial/models_import.dart.md ':include')

#### Export WeatherApiClient

Now that we have our class created with our two methods, let's go ahead and export it in the barrel file. Inside of `repositories.dart` go ahead and add:

[repositories.dart](_snippets/flutter_weather_tutorial/weather_api_client_export.dart.md ':include')

#### What next

We've got our `DataProvider` done so it's time to move up to the next layer of our app's architecture: the **repository layer**.

## Repository

> The `WeatherRepository` serves as an abstraction between the client code and the data provider so that as a developer working on features, you don't have to know where the data is coming from. Our `WeatherRepository` will have a dependency on our `WeatherApiClient` that we just created and it will expose a single public method called, you guessed it, `getWeather(String city)`. No one needs to know that under the hood we need to make two API calls (one for locationId and one for weather) because no one really cares. All we care about is getting the `Weather` for a given city.

#### Creating Our Weather Repository

This file can live in our repository folder. So go ahead and create a file called `weather_repository.dart` and open it up.

Our `WeatherRepository` is quite simple and should look something like this:

[weather_repository.dart](_snippets/flutter_weather_tutorial/weather_repository.dart.md ':include')

#### Export WeatherRepository in Barrel

Go ahead and open up `repositories.dart` and export this like so:

[repositories.dart](_snippets/flutter_weather_tutorial/weather_repository_export.dart.md ':include')

Awesome! We are now ready to move up to the business logic layer and start building our `WeatherBloc`.

## Business Logic (Bloc)

> Our `WeatherBloc` is responsible for receiving `WeatherEvents` and converting them into `WeatherStates`. It will have a dependency on `WeatherRepository` so that it can retrieve the `Weather` when a user inputs a city of their choice.

#### Creating Our First Bloc

We will create a few Blocs during this tutorial, so lets create a folder inside of `lib` called `blocs`. Again since we will have multiple blocs, let's first create a barrel file called `blocs.dart` inside our `blocs` folder.

Before jumping into the Bloc we need to define what events our `WeatherBloc` will be handling as well as how we are going to represent our `WeatherState`. To keep our files small, we will separate `event` `state` and `bloc` into three files.

#### Weather Event

Let's create a file called `weather_event.dart` inside of the `blocs` folder. For simplicity, we're going to start off by having a single event called `WeatherRequested`.

We can define it like:

[weather_event.dart](_snippets/flutter_weather_tutorial/fetch_weather_event.dart.md ':include')

Whenever a user inputs a city, we will `add` a `WeatherRequested` event with the given city and our bloc will be responsible for figuring out what the weather is there and returning a new `WeatherState`.

Then let's export the class in our barrel file. Inside of `blocs.dart` please add:

[blocs.dart](_snippets/flutter_weather_tutorial/weather_event_export.dart.md ':include')

#### Weather State

Next up let's create our `state` file. Inside of the `blocs` folder go ahead and create a file named `weather_state.dart` where our `weatherState` will live.

For the current application, we will have 4 possible states:

- `WeatherInitial` - our initial state which will have no weather data because the user has not yet selected a city
- `WeatherLoadInProgress` - a state which will occur while we are fetching the weather for a given city
- `WeatherLoadSuccess` - a state which will occur if we were able to successfully fetch weather for a given city.
- `WeatherLoadFailure` - a state which will occur if we were unable to fetch weather for a given city.

We can represent these states like so:

[weather_state.dart](_snippets/flutter_weather_tutorial/weather_state.dart.md ':include')

Then let's export this class in our barrel file. Inside of `blocs.dart` go ahead and add:

[blocs.dart](_snippets/flutter_weather_tutorial/weather_state_export.dart.md ':include')

Now that we have our `Events` and our `States` defined and implemented we are ready to make our `WeatherBloc`.

#### Weather Bloc

> Our `WeatherBloc` is very straightforward. To recap, it converts `WeatherEvents` into `WeatherStates` and has a dependency on the `WeatherRepository`.

?> **Tip:** Check out the [Bloc VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) in order to take advantage of the bloc snippets and even further improve your efficiency and development speed.

Go ahead and create a file inside of the `blocs` folder called `weather_bloc.dart` and add the following:

[weather_bloc.dart](_snippets/flutter_weather_tutorial/weather_bloc.dart.md ':include')

We set our `initialState` to `WeatherInitial` since initially, the user has not selected a city. Then, all that's left is to implement `mapEventToState`.

Since we are only handling the `WeatherRequested` event all we need to do is `yield` our `WeatherLoadInProgress` state when we get a `WeatherRequested` event and then try to get the weather from the `WeatherRepository`.

If we are able to successfully retrieve the weather we then `yield` a `WeatherLoadSuccess` state and if we are unable to retrieve the weather, we `yield` a `WeatherLoadFailure` state.

Now export this class in `blocs.dart`:

[blocs.dart](_snippets/flutter_weather_tutorial/weather_bloc_export.dart.md ':include')

That's all there is to it! Now we're ready to move on to the final layer: the presentation layer.

## Presentation

### Setup

As you've probably already seen in other tutorials, we're going to create a `SimpleBlocDelegate` so that we can see all state transitions in our application. Let's go ahead and create `simple_bloc_delegate.dart` and create our own custom delegate.

[simple_bloc_delegate.dart](_snippets/flutter_weather_tutorial/simple_bloc_delegate.dart.md ':include')

We can then import it into `main.dart` file and set our delegate like so:

[main.dart](_snippets/flutter_weather_tutorial/main1.dart.md ':include')

Lastly, we need to create our `WeatherRepository` and inject it into our `App` widget (which we will create in the next step).

[main.dart](_snippets/flutter_weather_tutorial/main2.dart.md ':include')

### App Widget

Our `App` widget is going to start off as a `StatelessWidget` which has the `WeatherRepository` injected and builds the `MaterialApp` with our `Weather` widget (which we will create in the next step). We are using the `BlocProvider` widget to create an instance of our `WeatherBloc` and make it available to the `Weather` widget and its children. In addition, the `BlocProvider` manages building and closing the `WeatherBloc`.

[main.dart](_snippets/flutter_weather_tutorial/app.dart.md ':include')

### Weather

Now we need to create our `Weather` Widget. Go ahead and make a folder called `widgets` inside of `lib` and create a barrel file inside called `widgets.dart`. Next create a file called `weather.dart`.

> Our Weather Widget will be a `StatelessWidget` responsible for rendering the various weather data.

#### Creating Our Stateless Widget

[weather.dart](_snippets/flutter_weather_tutorial/weather_widget.dart.md ':include')

All that's happening in this widget is we're using `BlocBuilder` with our `WeatherBloc` in order to rebuild our UI based on state changes in our `WeatherBloc`.

Go ahead and export `Weather` in the `widgets.dart` file.

You'll notice that we are referencing a `CitySelection`, `Location`, `LastUpdated`, and `CombinedWeatherTemperature` widget which we will create in the following sections.

### Location Widget

Go ahead and create a file called `location.dart` inside of the `widgets` folder.

> Our `Location` widget is simple; it displays the current location.

[location.dart](_snippets/flutter_weather_tutorial/location.dart.md ':include')

Make sure to export this in the `widgets.dart` file.

### Last Updated

Next up create a `last_updated.dart` file inside the `widgets` folder.

> Our `LastUpdated` widget is also super simple; it displays the last updated time so that users know how fresh the weather data is.

[last_updated.dart](_snippets/flutter_weather_tutorial/last_updated.dart.md ':include')

Make sure to export this in the `widgets.dart` file.

?> **Note:** We are using [`TimeOfDay`](https://api.flutter.dev/flutter/material/TimeOfDay-class.html) to format the `DateTime` into a more human-readable format.

### Combined Weather Temperature

Next up create a `combined_weather_temperature.dart` file inside the `widgets` folder.

> The `CombinedWeatherTemperature` widget is a compositional widget which displays the current weather along with the temperature. We are still going to modularize the `Temperature` and `WeatherConditions` widgets so that they can all be reused.

[combined_weather_temperature.dart](_snippets/flutter_weather_tutorial/combined_weather_temperature.dart.md ':include')

Make sure to export this in the `widgets.dart` file.

?> **Note:** We are using two unimplemented widgets: `WeatherConditions` and `Temperature` which we will create next.

### Weather Conditions

Next up create a `weather_conditions.dart` file inside the `widgets` folder.

> Our `WeatherConditions` widget will be responsible for displaying the current weather conditions (clear, showers, thunderstorms, etc...) along with a matching icon.

[weather_conditions.dart](_snippets/flutter_weather_tutorial/weather_conditions.dart.md ':include')

Make sure to export this in the `widgets.dart` file.

Here you can see we are using some assets. Please download them from [here](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/assets) and add them to the `assets/` directory we created at the beginning of the project.

?> **Tip:** Check out [icons8](https://icons8.com/icon/set/weather/office) for the assets used in this tutorial.

### Temperature

Next up create a `temperature.dart` file inside the `widgets` folder.

> Our `Temperature` widget will be responsible for displaying the average, min, and max temperatures.

[temperature.dart](_snippets/flutter_weather_tutorial/temperature.dart.md ':include')

Make sure to export this in the `widgets.dart` file.

### City Selection

The last thing we need to implement to have a functional app is out `CitySelection` widget which allows users to type in the name a city. Go ahead and create a `city_selection.dart` file inside the `widgets` folder.

> The `CitySelection` widget will allow users to input a city name and pass the selected city back to the `App` widget.

[city_selection.dart](_snippets/flutter_weather_tutorial/city_selection.dart.md ':include')

It needs to be a `StatefulWidget` because it has to maintain a `TextController`.

?> **Note:** When we press the search button we use `Navigator.pop` and pass the current text from our `TextController` back to the previous view.

Make sure to export this in the `widgets.dart` file.

## Run the App

Now that we have created all our widgets, let's go back to the `main.dart` file. You'll see we need to import our `Weather` widget, so go ahead and add this line up top.

[main.dart](_snippets/flutter_weather_tutorial/widgets_import.dart.md ':include')

Then you can go ahead and run the app with `flutter run` in the terminal. Go ahead and select a city and you'll notice it has a few problems:

- The background is white and so is the text making it very hard to read
- We have no way to refresh the weather data after it is fetched
- The UI is very plain
- Everything is in Celsius and we have no way to change the units

Let's address these problems and take our Weather App to the next level!

## Pull-To-Refresh

> In order to support pull-to-refresh we will need to update our `WeatherEvent` to handle a second event: `WeatherRefreshRequested`. Go ahead and add the following code to `blocs/weather_event.dart`

[weather_event.dart](_snippets/flutter_weather_tutorial/refresh_weather_event.dart.md ':include')

Next, we need to update our `mapEventToState` inside of `weather_bloc.dart` to handle a `WeatherRefreshRequested` event. Go ahead and add this `if` statement below the existing one.

[weather_bloc.dart](_snippets/flutter_weather_tutorial/refresh_weather_bloc.dart.md ':include')

Here we are just creating a new event that will ask our weatherRepository to make an API call to get the weather for the city.

We can refactor `mapEventToState` to use some private helper functions in order to keep the code organized and easy to follow:

[weather_bloc.dart](_snippets/flutter_weather_tutorial/map_event_to_state_refactor.dart.md ':include')

Lastly, we need to update our presentation layer to use a `RefreshIndicator` widget. Let's go ahead and modify our `Weather` widget in `widgets/weather.dart`. There are a few things we need to do.

- Import `async` to the `weather.dart` file to handle `Future`

[weather.dart](_snippets/flutter_weather_tutorial/dart_async_import.dart.md ':include')

- Add a Completer

[weather.dart](_snippets/flutter_weather_tutorial/add_completer.dart.md ':include')

Since our `Weather` widget will need to maintain an instance of a `Completer`, we need to refactor it to be a `StatefulWidget`. Then, we can initialize the `Completer` in `initState`.

- Inside the widgets `build` method, let's wrap the `ListView` in a `RefreshIndicator` widget like so. Then return the `_refreshCompleter.future;` when the `onRefresh` callback happens.

[weather.dart](_snippets/flutter_weather_tutorial/refresh_indicator.dart.md ':include')

In order to use the `RefreshIndicator` we had to create a [`Completer`](https://api.dart.dev/stable/dart-async/Completer-class.html) which allows us to produce a `Future` which we can complete at a later time.

The last thing we need to do is complete the `Completer` when we receive a `WeatherLoadSuccess` state in order to dismiss the loading indicator once the weather has been updated.

[weather.dart](_snippets/flutter_weather_tutorial/bloc_consumer_refactor.dart.md ':include')

We converted our `BlocBuilder` into a `BlocConsumer` because we need to handle both rebuilding the UI based on state changes as well as performing side-effects (completing the `Completer`).

?> **Note:** `BlocConsumer` is identical to having a nested `BlocBuilder` within a `BlocListener`.

That's it! We now have solved problem #1 and users can refresh the weather by pulling down. Feel free to run `flutter run` again and try refreshing the weather.

Next, let's tackle the plain looking UI by creating a `ThemeBloc`.

## Dynamic Theming

> Our `ThemeBloc` is going to be responsible for converting `ThemeEvents` into `ThemeStates`.

Our `ThemeEvents` are going to consist of a single event called `WeatherChanged` which will be added whenever the weather conditions we are displaying have changed.

[theme_event.dart](_snippets/flutter_weather_tutorial/weather_changed_event.dart.md ':include')

Our `ThemeState` will consist of a `ThemeData` and a `MaterialColor` which we will use to enhance our UI.

[theme_state.dart](_snippets/flutter_weather_tutorial/theme_state.dart.md ':include')

Now, we can implement our `ThemeBloc` which should look like:

[theme_bloc.dart](_snippets/flutter_weather_tutorial/theme_bloc.dart.md ':include')

Even though it's a lot of code, the only thing in here is logic to convert a `WeatherCondition` to a new `ThemeState`.

We can now update our `main` a `ThemeBloc` provide it to our `App`.

[main.dart](_snippets/flutter_weather_tutorial/main3.dart.md ':include')

Our `App` widget can then use `BlocBuilder` to react to changes in `ThemeState`.

[app.dart](_snippets/flutter_weather_tutorial/app2.dart.md ':include')

?> **Note:** We are using `BlocProvider` to make our `ThemeBloc` globally available using `BlocProvider.of<ThemeBloc>(context)`.

The last thing we need to do is create a cool `GradientContainer` widget which will color our background with respect to the current weather conditions.

[gradient_container.dart](_snippets/flutter_weather_tutorial/gradient_container.dart.md ':include')

Now we can use our `GradientContainer` in our `Weather` widget like so:

[weather.dart](_snippets/flutter_weather_tutorial/integrate_gradient_container.dart.md ':include')

Since we want to "do something" in response to state changes in our `WeatherBloc`, we are using `BlocListener`. In this case, we are completing and resetting the `Completer` and are also adding the `WeatherChanged` event to the `ThemeBloc`.

?> **Tip:** Check out the [SnackBar Recipe](recipesfluttershowsnackbar.md) for more information about the `BlocListener` widget.

We are accessing our `ThemeBloc` via `BlocProvider.of<ThemeBloc>(context)` and are then adding a `WeatherChanged` event on each `WeatherLoad`.

We also wrapped our `GradientContainer` widget with a `BlocBuilder` of `ThemeBloc` so that we can rebuild the `GradientContainer` and it's children in response to `ThemeState` changes.

Awesome! We now have an app that looks way nicer (in my opinion :P) and have tackled problem #2.

All that's left is to handle unit conversion between celsius and fahrenheit. To do that we'll create a `Settings` widget and a `SettingsBloc`.

## Unit Conversion

We'll start off by creating our `SettingsBloc` which will convert `SettingsEvents` into `SettingsStates`.

Our `SettingsEvents` will consist of a single event: `TemperatureUnitsToggled`.

[settings_event.dart](_snippets/flutter_weather_tutorial/settings_event.dart.md ':include')

Our `SettingsState` will simply consist of the current `TemperatureUnits`.

[settings_state.dart](_snippets/flutter_weather_tutorial/settings_state.dart.md ':include')

Lastly, we need to create our `SettingsBloc`:

[settings_bloc.dart](_snippets/flutter_weather_tutorial/settings_bloc.dart.md ':include')

All we're doing is using `fahrenheit` if `TemperatureUnitsToggled` is added and the current units are `celsius` and vice versa.

Now we need to provide our `SettingsBloc` to our `App` widget in `main.dart`.

[main.dart](_snippets/flutter_weather_tutorial/main4.dart.md ':include')

Again, we're making `SettingsBloc` globally accessible using `BlocProvider` and we are also closing it in the `close` callback. This time, however, since we are exposing more than one Bloc using `BlocProvider` at the same level we can eliminate some nesting by using the `MultiBlocProvider` widget.

Now we need to create our `Settings` widget from which users can toggle the units.

[settings.dart](_snippets/flutter_weather_tutorial/settings.dart.md ':include')

We're using `BlocProvider` to access the `SettingsBloc` via the `BuildContext` and then using `BlocBuilder` to rebuild our UI based on `SettingsState` changed.

Our UI consists of a `ListView` with a single `ListTile` which contains a `Switch` that users can toggle to select celsius vs. fahrenheit.

?> **Note:** In the switch's `onChanged` method we add a `TemperatureUnitsToggled` event to notify the `SettingsBloc` that the temperature units have changed.

Next, we need to allow users to get to the `Settings` widget from our `Weather` widget.

We can do that by adding a new `IconButton` in our `AppBar`.

[weather.dart](_snippets/flutter_weather_tutorial/settings_button.dart.md ':include')

We're almost done! We just need to update our `Temperature` widget to respond to the current units.

[temperature.dart](_snippets/flutter_weather_tutorial/update_temperature.dart.md ':include')

And lastly, we need to inject the `TemperatureUnits` into the `Temperature` widget.

[consolidated_weather_temperature.dart](_snippets/flutter_weather_tutorial/inject_temperature_units.dart.md ':include')

That’s all there is to it! We’ve now successfully implemented a weather app in flutter using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) packages and we’ve successfully separated our presentation layer from our business logic.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_weather).
