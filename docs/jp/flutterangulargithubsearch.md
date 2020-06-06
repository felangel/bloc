# Flutter + AngularDart Github Search Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a Github Search app in Flutter and AngularDart to demonstrate how we can share the data and business logic layers between the two projects.

![demo](../assets/gifs/flutter_github_search.gif)

![demo](../assets/gifs/angular_github_search.gif)

## Common Github Search Library

> The Common Github Search library will contain models, the data provider, the repository, as well as the bloc that will be shared between AngularDart and Flutter.

### Setup

We'll start off by creating a new directory for our application.

[setup.sh](../_snippets/flutter_angular_github_search/common/setup1.sh.md ':include')

Next, we'll create the scaffold for the `common_github_search` library.

[setup.sh](../_snippets/flutter_angular_github_search/common/setup2.sh.md ':include')

We need to create a `pubspec.yaml` with the required dependencies.

[pubspec.yaml](../_snippets/flutter_angular_github_search/common/pubspec.yaml.md ':include')

Lastly, we need to install our dependencies.

[pub_get.sh](../_snippets/flutter_angular_github_search/common/pub_get.sh.md ':include')

That's it for the project setup! Now we can get to work on building out the `common_github_search` package.

### Github Client

> The `GithubClient` which will be providing raw data from the [Github API](https://developer.github.com/v3/).

?> **Note:** You can see a sample of what the data we get back will look like [here](https://api.github.com/search/repositories?q=dartlang).

Let's create `github_client.dart`.

[github_client.dart](../_snippets/flutter_angular_github_search/common/github_client.dart.md ':include')

?> **Note:** Our `GithubClient` is simply making a network request to Github's Repository Search API and converting the result into either a `SearchResult` or `SearchResultError` as a `Future`.

Next we need to define our `SearchResult` and `SearchResultError` models.

#### Search Result Model

Create `search_result.dart`.

[search_result.dart](../_snippets/flutter_angular_github_search/common/search_result.dart.md ':include')

?> **Note:** The `SearchResult` implementation depends on `SearchResultItem.fromJson` which we have not yet implemented.

?> **Note:** We aren't including properties that aren't going to be used in our model.

#### Search Result Item Model

Next, we'll create `search_result_item.dart`.

[search_result_item.dart](../_snippets/flutter_angular_github_search/common/search_result_item.dart.md ':include')

?> **Note:** Again, the `SearchResultItem` implementation dependes on `GithubUser.fromJson` which we have not yet implemented.

#### Github User Model

Next, we'll create `github_user.dart`.

[github_user.dart](../_snippets/flutter_angular_github_search/common/github_user.dart.md ':include')

At this point we have finished implementing `SearchResult` and its dependencies so next we'll move onto `SearchResultError`.

#### Search Result Error Model

Create `search_result_error.dart`.

[search_result_error.dart](../_snippets/flutter_angular_github_search/common/search_result_error.dart.md ':include')

Our `GithubClient` is finished so next we'll move onto the `GithubCache` which will be responsible for [memoizing](https://en.wikipedia.org/wiki/Memoization) as a performance optimization.

### Github Cache

> Our `GithubCache` will be responsible for remembering all past queries so that we can avoid making unnecessary network requests to the Github API. This will also help improve our application's performance.

Create `github_cache.dart`.

[github_cache.dart](../_snippets/flutter_angular_github_search/common/github_cache.dart.md ':include')

Now we're ready to create our `GithubRepository`!

### Github Repository

> The Github Repository is responsible for creating an abstraction between the data layer (`GithubClient`) and the Business Logic Layer (`Bloc`). This is also where we're going to put our `GithubCache` to use.

Create `github_repository.dart`.

[github_repository.dart](../_snippets/flutter_angular_github_search/common/github_repository.dart.md ':include')

?> **Note:** The `GithubRepository` has a dependency on the `GithubCache` and the `GithubClient` and abstracts the underlying implementation. Our application never has to know about how the data is being retrieved or where it's coming from since it shouldn't care. We can change how the repository works at any time and as long as we don't change the interface we shouldn't need to change any client code.

At this point, we've completed the data provider layer and the repository layer so we're ready to move on to the business logic layer.

### Github Search Event

> Our Bloc will be notified when a user has typed the name of a repository which we will represent as a `TextChanged` `GithubSearchEvent`.

Create `github_search_event.dart`.

[github_search_event.dart](../_snippets/flutter_angular_github_search/common/github_search_event.dart.md ':include')

?> **Note:** We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare instances of `GithubSearchEvent`; by default, the equality operator returns true if and only if this and other are the same instance.

### Github Search State

Our presentation layer will need to have several pieces of information in order to properly lay itself out:

- `SearchStateEmpty`- will tell the presentation layer that no input has been given by the user

- `SearchStateLoading`- will tell the presentation layer it has to display some sort of loading indicator
- `SearchStateSuccess`- will tell the presentation layer that it has data to present

  - `items`- will be the `List<SearchResultItem>` which will be displayed

- `SearchStateError`- will tell the presentation layer that an error has occurred while fetching repositories
  - `error`- will be the exact error that occurred

We can now create `github_search_state.dart` and implement it like so.

[github_search_state.dart](../_snippets/flutter_angular_github_search/common/github_search_state.dart.md ':include')

?> **Note:** We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare instances of `GithubSearchState`; by default, the equality operator returns true if and only if this and other are the same instance.

Now that we have our Events and States implemented, we can create our `GithubSearchBloc`.

### Github Search Bloc

Create `github_search_bloc.dart`

[github_search_bloc.dart](../_snippets/flutter_angular_github_search/common/github_search_bloc.dart.md ':include')

?> **Note:** Our `GithubSearchBloc` converts `GithubSearchEvent` to `GithubSearchState` and has a dependency on the `GithubRepository`.

?> **Note:** We override the `transformEvents` method to [debounce](http://reactivex.io/documentation/operators/debounce.html) the `GithubSearchEvents`.

?> **Note:** We override `onTransition` so that we can log any time a state change occurs.

Awesome! We're all done with our `common_github_search` package.
The finished product should look like [this](https://github.com/felangel/Bloc/tree/master/examples/github_search/common_github_search).

Next, we'll work on the Flutter implementation.

## Flutter Github Search

> Flutter Github Search will be a Flutter application which reuses the models, data providers, repositories, and blocs from `common_github_search` to implement Github Search.

### Setup

We need to start by creating a new Flutter project in our `github_search` directory at the same level as `common_github_search`.

[flutter_create.sh](../_snippets/flutter_angular_github_search/flutter/flutter_create.sh.md ':include')

Next, we need to update our `pubspec.yaml` to include all the necessary dependencies.

[pubspec.yaml](../_snippets/flutter_angular_github_search/flutter/pubspec.yaml.md ':include')

?> **Note:** We are including our newly created `common_github_search` library as a dependency.

Now we need to install the dependencies.

[flutter_packages_get.sh](../_snippets/flutter_angular_github_search/flutter/flutter_packages_get.sh.md ':include')

That's it for project setup and since the `common_github_search` package contains our data layer as well as our business logic layer all we need to build is the presentation layer.

### Search Form

We're going to need to create a form with a `SearchBar` and `SearchBody` widget.

- `SearchBar` will be responsible for taking user input.
- `SearchBody` will be responsible for displaying search results, loading indicators, and errors.

Let's create `search_form.dart`.

> Our `SearchForm` will be a `StatelessWidget` which renders the `SearchBar` and `SearchBody` widgets.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_form.dart.md ':include')

Next, we'll implement `_SearchBar`.

### Search Bar

> `SearchBar` is also going to be a `StatefulWidget` because it will need to maintain its own `TextController` so that we can keep track of what a user has entered as input.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_bar.dart.md ':include')

?> **Note:** `_SearchBar` accesses `GitHubSearchBloc` via `BlocProvider.of<GithubSearchBloc>(context)` and notifies the bloc of `TextChanged` events.

We're done with `_SearchBar`, now onto `_SearchBody`.

### Search Body

> `SearchBody` is a `StatelessWidget` which will be responsible for displaying search results, errors, and loading indicators. It will be the consumer of the `GithubSearchBloc`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_body.dart.md ':include')

?> **Note:** `_SearchBody` also accesses `GithubSearchBloc` via `BlocProvider` and uses `BlocBuilder` in order to rebuild in response to state changes.

If our state is `SearchStateSuccess` we render `_SearchResults` which we will implement next.

### Search Results

> `SearchResults` is a `StatelessWidget` which takes a `List<SearchResultItem>` and displays them as a list of `SearchResultItems`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_results.dart.md ':include')

?> **Note:** We use `ListView.builder` in order to construct a scrollable list of `SearchResultItem`.

It's time to implement `_SearchResultItem`.

### Search Result Item

> `SearchResultItem` is a `StatelessWidget` and is responsible for rendering the information for a single search result. It is also responsible for handling user interaction and navigating to the repository url on a user tap.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_result_item.dart.md ':include')

?> **Note:** We use the [url_launcher](https://pub.dev/packages/url_launcher) package to open external urls.

### Putting it all together

At this point our `search_form.dart` should look like

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_form_complete.dart.md ':include')

Now all that's left to do is implement our main app in `main.dart`.

[main.dart](../_snippets/flutter_angular_github_search/flutter/main.dart.md ':include')

?> **Note:** Our `GithubRepository` is created in `main` and injected into our `App`. Our `SearchForm` is wrapped in a `BlocProvider` which is responsible for initializing, closing, and making the instance of `GithubSearchBloc` available to the `SearchForm` widget and its children.

That’s all there is to it! We’ve now successfully implemented a github search app in Flutter using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) packages and we’ve successfully separated our presentation layer from our business logic.

The full source can be found [here](https://github.com/felangel/Bloc/tree/master/examples/github_search/flutter_github_search).

Finally, we're going to build our AngularDart Github Search app.

## AngularDart Github Search

> AngularDart Github Search will be an AngularDart application which reuses the models, data providers, repositories, and blocs from `common_github_search` to implement Github Search.

### Setup

We need to start by creating a new AngularDart project in our github_search directory at the same level as `common_github_search`.

[stagehand.sh](../_snippets/flutter_angular_github_search/angular/stagehand.sh.md ':include')

!> Activate stagehand by running `pub global activate stagehand`

We can then go ahead and replace the contents of `pubspec.yaml` with:

[pubspec.yaml](../_snippets/flutter_angular_github_search/angular/pubspec.yaml.md ':include')

### Search Form

Just like in our Flutter app, we're going to need to create a `SearchForm` with a `SearchBar` and `SearchBody` component.

> Our `SearchForm` component will implement `OnInit` and `OnDestroy` because it will need to create and close a `GithubSearchBloc`.

- `SearchBar` will be responsible for taking user input.
- `SearchBody` will be responsible for displaying search results, loading indicators, and errors.

Let's create `search_form_component.dart.`

[search_form_component.dart](../_snippets/flutter_angular_github_search/angular/search_form_component.dart.md ':include')

?> **Note:** The `GithubRepository` is injected into the `SearchFormComponent`.

?> **Note:** The `GithubSearchBloc` is created and closed by the `SearchFormComponent`.

Our template (`search_form_component.html`) will look like:

[search_form_component.html](../_snippets/flutter_angular_github_search/angular/search_form_component.html.md ':include')

Next, we'll implement the `SearchBar` Component.

### Search Bar

> `SearchBar` is a component which will be responsible for taking in user input and notifying the `GithubSearchBloc` of text changes.

Create `search_bar_component.dart`.

[search_bar_component.dart](../_snippets/flutter_angular_github_search/angular/search_bar_component.dart.md ':include')

?> **Note:** `SearchBarComponent` has a dependency on `GitHubSearchBloc` because it is responsible for notifying the bloc of `TextChanged` events.

Next, we can create `search_bar_component.html`.

[search_bar_component.html](../_snippets/flutter_angular_github_search/angular/search_bar_component.html.md ':include')

We're done with `SearchBar`, now onto `SearchBody`.

### Search Body

> `SearchBody` is a component which will be responsible for displaying search results, errors, and loading indicators. It will be the consumer of the `GithubSearchBloc`.

Create `search_body_component.dart`

[search_body_component.dart](../_snippets/flutter_angular_github_search/angular/search_body_component.dart.md ':include')

?> **Note:** `SearchBodyComponent` has a dependency on `GithubSearchState` which is provided by the `GithubSearchBloc` using the `angular_bloc` bloc pipe.

Create `search_body_component.html`

[search_body_component.html](../_snippets/flutter_angular_github_search/angular/search_body_component.html.md ':include')

If our state `isSuccess` we render `SearchResults` which we will implement next.

### Search Results

> `SearchResults` is a component which takes a `List<SearchResultItem>` and displays them as a list of `SearchResultItems`.

Create `search_results_component.dart`

[search_results_component.dart](../_snippets/flutter_angular_github_search/angular/search_results_component.dart.md ':include')

Next up we'll create `search_results_component.html`.

[search_results_component.html](../_snippets/flutter_angular_github_search/angular/search_results_component.html.md ':include')

?> **Note:** We use `ngFor` in order to construct a list of `SearchResultItem` components.

It's time to implement `SearchResultItem`.

### Search Result Item

> `SearchResultItem` is a component that is responsible for rendering the information for a single search result. It is also responsible for handling user interaction and navigating to the repository url on a user tap.

Create `search_result_item_component.dart`.

[search_result_item_component.dart](../_snippets/flutter_angular_github_search/angular/search_result_item_component.dart.md ':include')

and the corresponding template in `search_result_item_component.html`.

[search_result_item_component.html](../_snippets/flutter_angular_github_search/angular/search_result_item_component.html.md ':include')

### Putting it all together

We have all of our components and now it's time to put them all together in our `app_component.dart`.

[app_component.dart](../_snippets/flutter_angular_github_search/angular/app_component.dart.md ':include')

?> **Note:** We're creating the `GithubRepository` in the `AppComponent` and injecting it into the `SearchForm` component.

That’s all there is to it! We’ve now successfully implemented a github search app in AngularDart using the `bloc` and `angular_bloc` packages and we’ve successfully separated our presentation layer from our business logic.

The full source can be found [here](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search).

## Summary

In this tutorial we created a Flutter and AngularDart app while sharing all of the models, data providers, and blocs between the two.

The only thing we actually had to write twice was the presentation layer (UI) which is awesome in terms of efficiency and development speed. In addition, it's fairly common for web apps and mobile apps to have different user experiences and styles and this approach really demonstrates how easy it is to build two apps that look totally different but share the same data and business logic layers.

The full source can be found [here](https://github.com/felangel/Bloc/tree/master/examples/github_search).
