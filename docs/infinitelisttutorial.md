# Infinite List Tutorial

> In this tutorial, we’re going to be implementing an app which fetches data over the network and loads it as a user scrolls using Flutter and the bloc library.

## Setup

We’ll start off by creating a brand new Flutter project

```bash
flutter create flutter_infinite_list
```

We can then go ahead and replace the contents of pubspec.yaml with

```yaml
name: flutter_infinite_list
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.0.0-dev.68.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: 0.4.11
  http: 0.12.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

and then install all of our dependencies

```bash
flutter packages get
```

## REST API

For this demo application, we’ll be using [jsonplaceholder](http://jsonplaceholder.typicode.com) as our data source.

?> jsonplaceholder is an online REST API which serves fake data; it’s very useful for building prototypes.

Open a new tab in your browser and visit https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 to see what the API returns.

```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
  }
]
```

?> **Note:** in our url we specified the start and limit as query parameters to the GET request.

Great, now that we know what our data is going to look like, let’s create the model.

## Data Model

Create `post.dart` and let’s get to work creating the model of our Post object.

```dart
class Post {
  final int id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  String toString() => 'Post { id: $id }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ body.hashCode;
}
```

`Post` is just a class with an `id`, `title`, and `body`.

?> We override the `toString` function in order to have a custom string representation of our `Post` for later.

?> We override the `==` operator as well as `hashCode` so that we can compare `Posts`; by default, the equality operator returns true if and only if this and other are the same object.

Now that we have our `Post` object model, let’s start working on the Business Logic Component (bloc).

## Post Events

Before we dive into the implementation, we need to define what our `PostBloc` is going to be doing.

At a high level, it will be responding to user input (scrolling) and fetching more posts in order for the presentation layer to display them. Let’s start by creating our `Event`.

Our `PostBloc` will only be responding to a single event; `Fetch` which will be dispatched by the presentation layer whenever it needs more Posts to present. Since our `Fetch` event is a type of `PostEvent` we can create `post_event.dart` and implement the event like so.

```dart
abstract class PostEvent {}

class Fetch extends PostEvent {
  @override
  String toString() => 'Fetch';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fetch && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
```

?> Again, we are overriding `toString` for an easier to read string representation of our event along with `==` and `hashCode` so that we can compare instances for equality.

To recap, our `PostBloc` will be receiving `PostEvents` and converting them to `PostStates`. We have defined all of our `PostEvents` (Fetch) so next let’s define our `PostState`.

## Post States

Our presentation layer will need to have several pieces of information in order to properly lay itself out:

- `PostUninitialized`- will tell the presentation layer it needs to render a loading indicator while the initial batch of posts are loaded

- `PostInitialized`- will tell the presentation layer it has content to render
  - `posts`- will be the `List<Post>` which will be displayed
  - `hasError`- will tell the presentation layer whether or not an error has occurred while fetching posts
  - `hasReachedMax`- will tell the presentation layer whether or not it has reach the maximum number of posts

We can now create `post_state.dart` and implement it like so.

```dart
import 'package:flutter_infinite_list/models/models.dart';

abstract class PostState {}

class PostUninitialized extends PostState {
  @override
  String toString() => 'PostUninitialized';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostUninitialized && runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
}

class PostInitialized extends PostState {
  final List<Post> posts;
  final bool hasError;
  final bool hasReachedMax;

  PostInitialized({
    this.hasError,
    this.posts,
    this.hasReachedMax,
  });

  factory PostInitialized.success(List<Post> posts) {
    return PostInitialized(
      posts: posts,
      hasError: false,
      hasReachedMax: false,
    );
  }

  factory PostInitialized.failure() {
    return PostInitialized(
      posts: [],
      hasError: true,
      hasReachedMax: false,
    );
  }

  PostInitialized copyWith({
    List<Post> posts,
    bool hasError,
    bool hasReachedMax,
  }) {
    return PostInitialized(
      posts: posts ?? this.posts,
      hasError: hasError ?? this.hasError,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'PostInitialized { posts: ${posts.length}, hasError: $hasError, hasReachedMax: $hasReachedMax }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostInitialized &&
          runtimeType == other.runtimeType &&
          posts == other.posts &&
          hasError == other.hasError &&
          hasReachedMax == other.hasReachedMax;

  @override
  int get hashCode =>
      posts.hashCode ^ hasError.hashCode ^ hasReachedMax.hashCode;
}
```

?> We use the factory pattern for convenience and readability; instead of manually creating instances of PostState, we can use the different factories like: `PostInitialized.failure()`.

?> We implemented `copyWith` so that we can copy an instance of `PostInitialized` and update zero or more properties conveniently (this will come in handy later ).

Now that we have our `Events` and `States` implemented, we can create our `PostBloc`.

## Post Bloc

For simplicity, our `PostBloc` will have a direct dependency on an `http client`; however, in a production application you might want instead inject an api client and use the repository pattern [docs](./architecture.md).

Let’s create `post_bloc.dart` and create our empty `PostBloc`.

```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/models/models.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  // TODO: implement initialState
  PostState get initialState => null;

  @override
  Stream<PostState> mapEventToState(
    PostState currentState,
    PostEvent event,
  ) async* {
    // TODO: implement mapEventToState
    yield null;
  }
}
```

?> **Note:** just from the class declaration we can tell that our PostBloc will be taking PostEvents as input and outputting PostStates.

We can start by implementing `initialState` which will be the state of our `PostBloc` before any events have been dispatched.

```dart
@override
get initialState => PostUninitialized();
```

Next, we need to implement `mapEventToState` which will be fired every time a `PostEvent` is dispatched.

```dart
@override
Stream<PostState> mapEventToState(currentState, event) async* {
  if (event is Fetch && !_hasReachedMax(currentState)) {
    try {
      if (currentState is PostUninitialized) {
        final posts = await _fetchPosts(0, 20);
        yield PostInitialized.success(posts);
      }
      if (currentState is PostInitialized) {
        final posts = await _fetchPosts(currentState.posts.length, 20);
        yield posts.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PostInitialized.success(currentState.posts + posts);
      }
    } catch (_) {
      yield PostInitialized.failure();
    }
  }
}

bool _hasReachedMax(PostState state) =>
  state is PostInitialized && state.hasReachedMax;

Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
  final response = await httpClient.get(
      'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((rawPost) {
      return Post(
        id: rawPost['id'],
        title: rawPost['title'],
        body: rawPost['body'],
      );
    }).toList();
  } else {
    throw Exception('error fetching posts');
  }
}
```

Our `PostBloc` will `yield` whenever there is a new state because it returns a `Stream<PostState>`. Check out [core concepts](https://felangel.github.io/bloc/#/coreconcepts?id=streams) for more information about `Streams` and other core concepts.

Now every time a `PostEvent` is dispatched, if it is a `Fetch` event and if our current state has not reached the max, our `PostBloc` will fetch the next 20 posts.

The API will return an empty array if we try to fetch beyond the max posts (100) so if we get back an empty array, our bloc will `yield` the currentState except we will set `hasReachedMax` to true.

If we cannot retrieve the posts, we throw an exception and `yield` `PostState.failure()`.

If we can retrieve the posts, we return `PostState.success()` which takes the entire list of posts.

One optimization we can make is to `debounce` the `Events` in order to prevent spamming our API unnecessarily. We can do this by overriding the `transform` method in our `PostBloc`.

?> **Note:** Overriding transform allows us to transform the Stream<Event> before mapEventToState is called. This allows for operations like distinct(), debounce(), etc... to be applied.

```dart
@override
Stream<PostEvent> transform(Stream<PostEvent> events) {
  return (events as Observable<PostEvent>)
      .debounce(Duration(milliseconds: 500));
}
```

Our finished `PostBloc` should now look like this:

```dart
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/models/models.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  Stream<PostEvent> transform(Stream<PostEvent> events) {
    return (events as Observable<PostEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => PostUninitialized();

  @override
  Stream<PostState> mapEventToState(currentState, event) async* {
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostUninitialized) {
          final posts = await _fetchPosts(0, 20);
          yield PostInitialized.success(posts);
        }
        if (currentState is PostInitialized) {
          final posts = await _fetchPosts(currentState.posts.length, 20);
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostInitialized.success(currentState.posts + posts);
        }
      } catch (_) {
        yield PostInitialized.failure();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostInitialized && state.hasReachedMax;

  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }
}
```

Great! Now that we’ve finished implementing the business logic all that’s left to do is implement the presentation layer.

## Presentation Layer

In our `main.dart` we can start by implementing our main function and calling `runApp` to render our root widget.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: HomePage(),
      ),
    );
  }
}
```

Next, we need to implement our `HomePage` widget which will present our posts and hook up to our `PostBloc`.

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final PostBloc _postBloc = PostBloc(httpClient: http.Client());
  final _scrollThreshold = 200.0;

  _HomePageState() {
    _scrollController.addListener(_onScroll);
    _postBloc.dispatch(Fetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _postBloc,
      builder: (BuildContext context, PostState state) {
        if (state is PostUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is PostInitialized) {
          if (state.hasError) {
            return Center(
              child: Text('failed to fetch posts'),
            );
          }
          if (state.posts.isEmpty) {
            return Center(
              child: Text('no posts'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.posts.length
                  ? BottomLoader()
                  : PostWidget(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
                ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _postBloc.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.dispatch(Fetch());
    }
  }
}
```

?> `HomePage` is a `StatefulWidget` because it will need to maintain a `ScrollController` as well as the `PostBloc`. In the `HomePageState`, we create our instances of `ScrollController` and `PostBloc`. In the constructor, we add a listener to our `ScrollController` so that we can respond to scroll events. Also, in the constructor, we need to dispatch a `Fetch` event so that when the app loads, it requests the initial batch of Posts.

Moving along, our build method returns a `BlocBuilder`. `BlocBuilder` is a Flutter widget from the [flutter_bloc package](https://pub.dartlang.org/packages/flutter_bloc) which handles building a widget in response to new bloc states. Anytime our `PostBloc` state changes, our builder function will be called with the new `PostState`.

!> We need to remember to clean up after ourselves and dispose our bloc when our StatefulWidget is disposed.

Whenever the user scrolls, we calculate how far away from the bottom of the page the user is and if the distance is ≤ our `_scrollThreshold` we dispatch a `Fetch` event in order to load more posts.

Next, we need to implement our `BottomLoader` widget which will indicate to the user that we are loading more posts.

```dart
class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
```

Lastly, we need to implement our `PostWidget` which will render an individual Post.

```dart
class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        post.id.toString(),
        style: TextStyle(fontSize: 10.0),
      ),
      title: Text('${post.title}'),
      isThreeLine: true,
      subtitle: Text(post.body),
      dense: true,
    );
  }
}
```

At this point, we should be able to run our app and everything should work; however, there’s one more thing we can do.

One added bonus of using the bloc library is that we can have access to all `Transitions` in one place.

> The change from one state to another is called a `Transition`.

?> A `Transition` consists of the current state, the event, and the next state.

Even though in this application we only have one bloc, it's fairly common in larger applications to have many blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocDelegate`.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition.toString());
  }
}
```

?> All we need to do is extend `BlocDelegate` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocDelegate`, we just need to tweak our main function.

```dart
void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(MyApp());
}
```

Now when we run our application, every time a Bloc `Transition` occurs we can see the transition printed to the console.

?> In practice, you can create different `BlocDelegates` and because every state change is recorded, we are able to very easily instrument our applications and track all user interactions and state changes in one place!

That’s all there is to it! We’ve now successfully implemented an infinite list in flutter using the [bloc](https://pub.dartlang.org/packages/bloc) and [flutter_bloc](https://pub.dartlang.org/packages/flutter_bloc) packages and we’ve successfully separated our presentation layer from our business logic.

Our `HomePage` has no idea where the `Posts` are coming from or how they are being retrieved. Conversely, our `PostBloc` has no idea how the `State` is being rendered, it simply converts events into states.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).