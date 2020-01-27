# Flutter + AngularDart Github Search Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a Github Search app in Flutter and AngularDart to demonstrate how we can share the data and business logic layers between the two projects.

![demo](./assets/gifs/flutter_github_search.gif)

![demo](./assets/gifs/angular_github_search.gif)

## Common Github Search Library

> The Common Github Search library will contain models, the data provider, the repository, as well as the bloc that will be shared between AngularDart and Flutter.

### Setup

We'll start off by creating a new directory for our application.

```bash
mkdir github_search && cd github_search
```

Next, we'll create the scaffold for the `common_github_search` library.

```bash
mkdir common_github_search
```

We need to create a `pubspec.yaml` with the required dependencies.

```yaml
name: common_github_search
description: Shared Code between AngularDart and Flutter
version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  meta: ^1.1.6
  bloc: ^3.0.0
  equatable: ^1.0.0
  http: ^0.12.0
```

Lastly, we need to install our dependencies.

```bash
pub get
```

That's it for the project setup! Now we can get to work on building out the `common_github_search` package.

### Github Client

> The `GithubClient` which will be providing raw data from the [Github API](https://developer.github.com/v3/).

?> **Note:** You can see a sample of what the data we get back will look like [here](https://api.github.com/search/repositories?q=dartlang).

Let's create `github_client.dart`.

```dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:common_github_search/common_github_search.dart';

class GithubClient {
  final String baseUrl;
  final http.Client httpClient;

  GithubClient({
    http.Client httpClient,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  }) : this.httpClient = httpClient ?? http.Client();

  Future<SearchResult> search(String term) async {
    final response = await httpClient.get(Uri.parse("$baseUrl$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}
```

?> **Note:** Our `GithubClient` is simply making a network request to Github's Repository Search API and converting the result into either a `SearchResult` or `SearchResultError` as a `Future`.

Next we need to define our `SearchResult` and `SearchResultError` models.

#### Search Result Model

Create `search_result.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class SearchResult {
  final List<SearchResultItem> items;

  const SearchResult({this.items});

  static SearchResult fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) =>
            SearchResultItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return SearchResult(items: items);
  }
}
```

?> **Note:** The `SearchResult` implementation depends on `SearchResultItem.fromJson` which we have not yet implemented.

?> **Note:** We aren't including properties that aren't going to be used in our model.

#### Search Result Item Model

Next, we'll create `search_result_item.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class SearchResultItem {
  final String fullName;
  final String htmlUrl;
  final GithubUser owner;

  const SearchResultItem({this.fullName, this.htmlUrl, this.owner});

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }
}
```

?> **Note:** Again, the `SearchResultItem` implementation dependes on `GithubUser.fromJson` which we have not yet implemented.

#### Github User Model

Next, we'll create `github_user.dart`.

```dart
class GithubUser {
  final String login;
  final String avatarUrl;

  const GithubUser({this.login, this.avatarUrl});

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}
```

At this point we have finished implementing `SearchResult` and its dependencies so next we'll move onto `SearchResultError`.

#### Search Result Error Model

Create `search_result_error.dart`.

```dart
class SearchResultError {
  final String message;

  const SearchResultError({this.message});

  static SearchResultError fromJson(dynamic json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }
}
```

Our `GithubClient` is finished so next we'll move onto the `GithubCache` which will be responsible for [memoizing](https://en.wikipedia.org/wiki/Memoization) as a performance optimization.

### Github Cache

> Our `GithubCache` will be responsible for remembering all past queries so that we can avoid making unnecessary network requests to the Github API. This will also help improve our application's performance.

Create `github_cache.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class GithubCache {
  final _cache = <String, SearchResult>{};

  SearchResult get(String term) => _cache[term];

  void set(String term, SearchResult result) => _cache[term] = result;

  bool contains(String term) => _cache.containsKey(term);

  void remove(String term) => _cache.remove(term);
}
```

Now we're ready to create our `GithubRepository`!

### Github Repository

> The Github Repository is responsible for creating an abstraction between the data layer (`GithubClient`) and the Business Logic Layer (`Bloc`). This is also where we're going to put our `GithubCache` to use.

Create `github_repository.dart`.

```dart
import 'dart:async';

import 'package:common_github_search/common_github_search.dart';

class GithubRepository {
  final GithubCache cache;
  final GithubClient client;

  GithubRepository(this.cache, this.client);

  Future<SearchResult> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term);
    } else {
      final result = await client.search(term);
      cache.set(term, result);
      return result;
    }
  }
}
```

?> **Note:** The `GithubRepository` has a dependency on the `GithubCache` and the `GithubClient` and abstracts the underlying implementation. Our application never has to know about how the data is being retrieved or where it's coming from since it shouldn't care. We can change how the repository works at any time and as long as we don't change the interface we shouldn't need to change any client code.

At this point, we've completed the data provider layer and the repository layer so we're ready to move on to the business logic layer.

### Github Search Event

> Our Bloc will be notified when a user has typed the name of a repository which we will represent as a `TextChanged` `GithubSearchEvent`.

Create `github_search_event.dart`.

```dart
import 'package:equatable/equatable.dart';

abstract class GithubSearchEvent extends Equatable {
  const GithubSearchEvent();
}

class TextChanged extends GithubSearchEvent {
  final String text;

  const TextChanged({this.text});

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'TextChanged { text: $text }';
}
```

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

```dart
import 'package:equatable/equatable.dart';

import 'package:common_github_search/common_github_search.dart';

abstract class GithubSearchState extends Equatable {
  const GithubSearchState();

  @override
  List<Object> get props => [];
}

class SearchStateEmpty extends GithubSearchState {}

class SearchStateLoading extends GithubSearchState {}

class SearchStateSuccess extends GithubSearchState {
  final List<SearchResultItem> items;

  const SearchStateSuccess(this.items);

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class SearchStateError extends GithubSearchState {
  final String error;

  const SearchStateError(this.error);

  @override
  List<Object> get props => [error];
}
```

?> **Note:** We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare instances of `GithubSearchState`; by default, the equality operator returns true if and only if this and other are the same instance.

Now that we have our Events and States implemented, we can create our `GithubSearchBloc`.

### Github Search Bloc

Create `github_search_bloc.dart`

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import 'package:common_github_search/common_github_search.dart';

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  final GithubRepository githubRepository;

  GithubSearchBloc({@required this.githubRepository});

  @override
  Stream<GithubSearchState> transformEvents(
    Stream<GithubSearchEvent> events,
    Stream<GithubSearchState> Function(GithubSearchEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  void onTransition(
      Transition<GithubSearchEvent, GithubSearchState> transition) {
    print(transition);
  }

  @override
  GithubSearchState get initialState => SearchStateEmpty();

  @override
  Stream<GithubSearchState> mapEventToState(
    GithubSearchEvent event,
  ) async* {
    if (event is TextChanged) {
      final String searchTerm = event.text;
      if (searchTerm.isEmpty) {
        yield SearchStateEmpty();
      } else {
        yield SearchStateLoading();
        try {
          final results = await githubRepository.search(searchTerm);
          yield SearchStateSuccess(results.items);
        } catch (error) {
          yield error is SearchResultError
              ? SearchStateError(error.message)
              : SearchStateError('something went wrong');
        }
      }
    }
  }
}
```

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

```bash
flutter create flutter_github_search
```

Next, we need to update our `pubspec.yaml` to include all the necessary dependencies.

```yaml
name: flutter_github_search
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  url_launcher: ^4.0.3
  common_github_search:
    path: ../common_github_search

flutter:
  uses-material-design: true
```

?> **Note:** We are including our newly created `common_github_search` library as a dependency.

Now we need to install the dependencies.

```bash
flutter packages get
```

That's it for project setup and since the `common_github_search` package contains our data layer as well as our business logic layer all we need to build is the presentation layer.

### Search Form

We're going to need to create a form with a `SearchBar` and `SearchBody` widget.

- `SearchBar` will be responsible for taking user input.
- `SearchBody` will be responsible for displaying search results, loading indicators, and errors.

Let's create `search_form.dart`.

> Our `SearchForm` will be a `StatelessWidget` which renders the `SearchBar` and `SearchBody` widgets.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}
```

Next, we'll implement `_SearchBar`.

### Search Bar

> `SearchBar` is also going to be a `StatefulWidget` because it will need to maintain its own `TextController` so that we can keep track of what a user has entered as input.

```dart
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = BlocProvider.of<GithubSearchBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _githubSearchBloc.add(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(TextChanged(text: ''));
  }
}
```

?> **Note:** `_SearchBar` accesses `GitHubSearchBloc` via `BlocProvider.of<GithubSearchBloc>(context)` and notifies the bloc of `TextChanged` events.

We're done with `_SearchBar`, now onto `_SearchBody`.

### Search Body

> `SearchBody` is a `StatelessWidget` which will be responsible for displaying search results, errors, and loading indicators. It will be the consumer of the `GithubSearchBloc`.

```dart
class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}
```

?> **Note:** `_SearchBody` also accesses `GithubSearchBloc` via `BlocProvider` and uses `BlocBuilder` in order to rebuild in response to state changes.

If our state is `SearchStateSuccess` we render `_SearchResults` which we will implement next.

### Search Results

> `SearchResults` is a `StatelessWidget` which takes a `List<SearchResultItem>` and displays them as a list of `SearchResultItems`.

```dart
class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}
```

?> **Note:** We use `ListView.builder` in order to construct a scrollable list of `SearchResultItem`.

It's time to implement `_SearchResultItem`.

### Search Result Item

> `SearchResultItem` is a `StatelessWidget` and is responsible for rendering the information for a single search result. It is also responsible for handling user interaction and navigating to the repository url on a user tap.

```dart
class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
```

?> **Note:** We use the [url_launcher](https://pub.dev/packages/url_launcher) package to open external urls.

### Putting it all together

At this point our `search_form.dart` should look like

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = BlocProvider.of<GithubSearchBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _githubSearchBloc.add(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
```

Now all that's left to do is implement our main app in `main.dart`.

```dart
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:flutter_github_search/search_form.dart';

void main() {
  final GithubRepository _githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );

  runApp(App(githubRepository: _githubRepository));
}

class App extends StatelessWidget {
  final GithubRepository githubRepository;

  const App({
    Key key,
    @required this.githubRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Search',
      home: Scaffold(
        appBar: AppBar(title: Text('Github Search')),
        body: BlocProvider(
          create: (context) =>
              GithubSearchBloc(githubRepository: githubRepository),
          child: SearchForm(),
        ),
      ),
    );
  }
}
```

?> **Note:** Our `GithubRepository` is created in `main` and injected into our `App`. Our `SearchForm` is wrapped in a `BlocProvider` which is responsible for initializing, closing, and making the instance of `GithubSearchBloc` available to the `SearchForm` widget and its children.

That’s all there is to it! We’ve now successfully implemented a github search app in Flutter using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) packages and we’ve successfully separated our presentation layer from our business logic.

The full source can be found [here](https://github.com/felangel/Bloc/tree/master/examples/github_search/flutter_github_search).

Finally, we're going to build our AngularDart Github Search app.

## AngularDart Github Search

> AngularDart Github Search will be an AngularDart application which reuses the models, data providers, repositories, and blocs from `common_github_search` to implement Github Search.

### Setup

We need to start by creating a new AngularDart project in our github_search directory at the same level as `common_github_search`.

```bash
stagehand web-angular
```

!> Activate stagehand by running `pub global activate stagehand`

We can then go ahead and replace the contents of `pubspec.yaml` with:

```yaml
name: angular_github_search
description: A web app that uses AngularDart Components

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  angular: ^5.3.0
  angular_components: ^0.13.0
  angular_bloc: ^3.0.0
  common_github_search:
    path: ../common_github_search

dev_dependencies:
  angular_test: ^2.0.0
  build_runner: ">=1.6.2 <2.0.0"
  build_test: ^0.10.2
  build_web_compilers: ">=1.2.0 <3.0.0"
  test: ^1.0.0
```

### Search Form

Just like in our Flutter app, we're going to need to create a `SearchForm` with a `SearchBar` and `SearchBody` component.

> Our `SearchForm` component will implement `OnInit` and `OnDestroy` because it will need to create and close a `GithubSearchBloc`.

- `SearchBar` will be responsible for taking user input.
- `SearchBody` will be responsible for displaying search results, loading indicators, and errors.

Let's create `search_form_component.dart.`

```dart
import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
    selector: 'search-form',
    templateUrl: 'search_form_component.html',
    directives: [
      SearchBarComponent,
      SearchBodyComponent,
    ],
    pipes: [
      BlocPipe
    ])
class SearchFormComponent implements OnInit, OnDestroy {
  @Input()
  GithubRepository githubRepository;

  GithubSearchBloc githubSearchBloc;

  @override
  void ngOnInit() {
    githubSearchBloc = GithubSearchBloc(
      githubRepository: githubRepository,
    );
  }

  @override
  void ngOnDestroy() {
    githubSearchBloc.close();
  }
}
```

?> **Note:** The `GithubRepository` is injected into the `SearchFormComponent`.

?> **Note:** The `GithubSearchBloc` is created and closed by the `SearchFormComponent`.

Our template (`search_form_component.html`) will look like:

```html
<div>
  <h1>Github Search</h1>
  <search-bar [githubSearchBloc]="githubSearchBloc"></search-bar>
  <search-body [state]="githubSearchBloc | bloc"></search-body>
</div>
```

Next, we'll implement the `SearchBar` Component.

### Search Bar

> `SearchBar` is a component which will be responsible for taking in user input and notifying the `GithubSearchBloc` of text changes.

Create `search_bar_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-bar',
  templateUrl: 'search_bar_component.html',
)
class SearchBarComponent {
  @Input()
  GithubSearchBloc githubSearchBloc;

  void onTextChanged(String text) {
    githubSearchBloc.add(TextChanged(text: text));
  }
}
```

?> **Note:** `SearchBarComponent` has a dependency on `GitHubSearchBloc` because it is responsible for notifying the bloc of `TextChanged` events.

Next, we can create `search_bar_component.html`.

```html
<label for="term" class="clip">Enter a search term</label>
<input
  id="term"
  placeholder="Enter a search term"
  class="input-reset outline-transparent glow o-50 bg-near-black near-white w-100 pv2 border-box b--white-50 br-0 bl-0 bt-0 bb-ridge mb3"
  autofocus
  (keyup)="onTextChanged($event.target.value)"
/>
```

We're done with `SearchBar`, now onto `SearchBody`.

### Search Body

> `SearchBody` is a component which will be responsible for displaying search results, errors, and loading indicators. It will be the consumer of the `GithubSearchBloc`.

Create `search_body_component.dart`

```dart
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'search-body',
  templateUrl: 'search_body_component.html',
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialIconComponent,
    SearchResultsComponent,
  ],
)
class SearchBodyComponent {
  @Input()
  GithubSearchState state;

  bool get isEmpty => state is SearchStateEmpty;
  bool get isLoading => state is SearchStateLoading;
  bool get isSuccess => state is SearchStateSuccess;
  bool get isError => state is SearchStateError;

  List<SearchResultItem> get items =>
      isSuccess ? (state as SearchStateSuccess).items : [];

  String get error => isError ? (state as SearchStateError).error : '';
}
```

?> **Note:** `SearchBodyComponent` has a dependency on `GithubSearchState` which is provided by the `GithubSearchBloc` using the `angular_bloc` bloc pipe.

Create `search_body_component.html`

```html
<div *ngIf="state != null" class="mw10">
  <div *ngIf="isEmpty" class="tc">
    <material-icon icon="info" class="light-blue"></material-icon>
    <p>Please enter a term to begin</p>
  </div>
  <div *ngIf="isLoading" class="tc"><material-spinner></material-spinner></div>
  <div *ngIf="isError" class="tc">
    <material-icon icon="error" class="light-red"></material-icon>
    <p>{{ error }}</p>
  </div>
  <div *ngIf="isSuccess">
    <div *ngIf="items.length == 0" class="tc">
      <material-icon icon="warning" class="light-yellow"></material-icon>
      <p>No Results</p>
    </div>
    <search-results [items]="items"></search-results>
  </div>
</div>
```

If our state `isSuccess` we render `SearchResults` which we will implement next.

### Search Results

> `SearchResults` is a component which takes a `List<SearchResultItem>` and displays them as a list of `SearchResultItems`.

Create `search_results_component.dart`

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'search-results',
  templateUrl: 'search_results_component.html',
  directives: [coreDirectives, SearchResultItemComponent],
)
class SearchResultsComponent {
  @Input()
  List<SearchResultItem> items;
}
```

Next up we'll create `search_results_component.html`.

```html
<ul class="list pa0 ma0">
  <li *ngFor="let item of items" class="pa2 cf">
    <search-result-item [item]="item"></search-result-item>
  </li>
</ul>
```

?> **Note:** We use `ngFor` in order to construct a list of `SearchResultItem` components.

It's time to implement `SearchResultItem`.

### Search Result Item

> `SearchResultItem` is a component that is responsible for rendering the information for a single search result. It is also responsible for handling user interaction and navigating to the repository url on a user tap.

Create `search_result_item_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-result-item',
  templateUrl: 'search_result_item_component.html',
)
class SearchResultItemComponent {
  @Input()
  SearchResultItem item;
}
```

and the corresponding template in `search_result_item_component.html`.

```html
<div class="fl w-10 h-auto">
  <img class="br-100" src="{{ item?.owner.avatarUrl }}" />
</div>
<div class="fl w-90 ph3">
  <h1 class="f5 ma0">{{ item.fullName }}</h1>
  <p>
    <a href="{{ item?.htmlUrl }}" class="light-blue" target="_blank"
      >{{ item?.htmlUrl }}</a
    >
  </p>
</div>
```

### Putting it all together

We have all of our components and now it's time to put them all together in our `app_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'my-app',
  template:
      '<search-form [githubRepository]="githubRepository"></search-form>',
  directives: [SearchFormComponent],
)
class AppComponent {
  final githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );
}
```

?> **Note:** We're creating the `GithubRepository` in the `AppComponent` and injecting it into the `SearchForm` component.

That’s all there is to it! We’ve now successfully implemented a github search app in AngularDart using the `bloc` and `angular_bloc` packages and we’ve successfully separated our presentation layer from our business logic.

The full source can be found [here](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search).

## Summary

In this tutorial we created a Flutter and AngularDart app while sharing all of the models, data providers, and blocs between the two.

The only thing we actually had to write twice was the presentation layer (UI) which is awesome in terms of efficiency and development speed. In addition, it's fairly common for web apps and mobile apps to have different user experiences and styles and this approach really demonstrates how easy it is to build two apps that look totally different but share the same data and business logic layers.

The full source can be found [here](https://github.com/felangel/Bloc/tree/master/examples/github_search).
