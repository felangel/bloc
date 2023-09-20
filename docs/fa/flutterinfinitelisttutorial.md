# Flutter Infinite List Tutorial

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> In this tutorial, we’re going to be implementing an app which fetches data over the network and loads it as a user scrolls using Flutter and the bloc library.

![demo](./assets/gifs/flutter_infinite_list.gif)

## Key Topics

- Observe state changes with [BlocObserver](/coreconcepts?id=blocobserver).
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), Flutter widget which provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), Flutter widget that handles building the widget in response to new states.
- Adding events with [context.read](/migration?id=❗contextbloc-and-contextrepository-are-deprecated-in-favor-of-contextread-and-contextwatch).⚡
- Prevent unnecessary rebuilds with [Equatable](/faqs?id=when-to-use-equatable).
- Use the `transformEvents` method with Rx.

## Setup

We’ll start off by creating a brand new Flutter project

```sh
flutter create flutter_infinite_list
```

We can then go ahead and replace the contents of pubspec.yaml with

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/pubspec.yaml ':include')

and then install all of our dependencies

```sh
flutter pub get
```

## Project Structure

```
├── lib
|   ├── posts
│   │   ├── bloc
│   │   │   └── post_bloc.dart
|   |   |   └── post_event.dart
|   |   |   └── post_state.dart
|   |   └── models
|   |   |   └── models.dart*
|   |   |   └── post.dart
│   │   └── view
│   │   |   ├── posts_page.dart
│   │   |   └── posts_list.dart
|   |   |   └── view.dart*
|   |   └── widgets
|   |   |   └── bottom_loader.dart
|   |   |   └── post_list_item.dart
|   |   |   └── widgets.dart*
│   │   ├── posts.dart*
│   ├── app.dart
│   ├── simple_bloc_observer.dart
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml
```

The application uses a feature-driven directory structure. This project structure enables us to scale the project by having self-contained features. In this example we will only have a single feature (the post feature) and it's split up into respective folders with barrel files, indicated by the asterisk (\*).

## REST API

For this demo application, we’ll be using [jsonplaceholder](http://jsonplaceholder.typicode.com) as our data source.

?> jsonplaceholder is an online REST API which serves fake data; it’s very useful for building prototypes.

Open a new tab in your browser and visit https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 to see what the API returns.

[posts.json](_snippets/flutter_infinite_list_tutorial/posts.json.md ':include')

?> **Note:** in our url we specified the start and limit as query parameters to the GET request.

Great, now that we know what our data is going to look like, let’s create the model.

## Data Model

Create `post.dart` and let’s get to work creating the model of our Post object.

[post.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/models/post.dart ':include')

`Post` is just a class with an `id`, `title`, and `body`.

?> We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare `Posts`. Without this, we would need to manually change our class to override equality and hashCode so that we could tell the difference between two `Posts` objects. See [the package](https://pub.dev/packages/equatable) for more details.

Now that we have our `Post` object model, let’s start working on the Business Logic Component (bloc).

## Post Events

Before we dive into the implementation, we need to define what our `PostBloc` is going to be doing.

At a high level, it will be responding to user input (scrolling) and fetching more posts in order for the presentation layer to display them. Let’s start by creating our `Event`.

Our `PostBloc` will only be responding to a single event; `PostFetched` which will be added by the presentation layer whenever it needs more Posts to present. Since our `PostFetched` event is a type of `PostEvent` we can create `bloc/post_event.dart` and implement the event like so.

[post_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_event.dart ':include')

To recap, our `PostBloc` will be receiving `PostEvents` and converting them to `PostStates`. We have defined all of our `PostEvents` (PostFetched) so next let’s define our `PostState`.

## Post States

Our presentation layer will need to have several pieces of information in order to properly lay itself out:

- `PostInitial`- will tell the presentation layer it needs to render a loading indicator while the initial batch of posts are loaded

- `PostSuccess`- will tell the presentation layer it has content to render
  - `posts`- will be the `List<Post>` which will be displayed
  - `hasReachedMax`- will tell the presentation layer whether or not it has reached the maximum number of posts
- `PostFailure`- will tell the presentation layer that an error has occurred while fetching posts

We can now create `bloc/post_state.dart` and implement it like so.

[post_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_state.dart ':include')

?> We implemented `copyWith` so that we can copy an instance of `PostSuccess` and update zero or more properties conveniently (this will come in handy later).

Now that we have our `Events` and `States` implemented, we can create our `PostBloc`.

## Post Bloc

For simplicity, our `PostBloc` will have a direct dependency on an `http client`; however, in a production application we suggest instead you inject an api client and use the repository pattern [docs](./architecture.md).

Let’s create `post_bloc.dart` and create our empty `PostBloc`.

[post_bloc_initial.dart](_snippets/flutter_infinite_list_tutorial/post_bloc_initial.dart.md ':include')

?> **Note:** Just from the class declaration we can tell that our PostBloc will be taking PostEvents as input and outputting PostStates.

Next, we need to register an event handler to handle incoming `PostFetched` events. In response to a `PostFetched` event, we will call `_fetchPosts` to fetch posts from the API.

[post_bloc_on_post_fetched.dart](_snippets/flutter_infinite_list_tutorial/post_bloc_on_post_fetched.dart.md ':include')

Our `PostBloc` will `emit` new states via the `Emitter<PostState>` provided in the event handler. Check out [core concepts](https://bloclibrary.dev/#/coreconcepts?id=streams) for more information.

Now every time a `PostEvent` is added, if it is a `PostFetched` event and there are more posts to fetch, our `PostBloc` will fetch the next 20 posts.

The API will return an empty array if we try to fetch beyond the maximum number of posts (100), so if we get back an empty array, our bloc will `emit` the currentState except we will set `hasReachedMax` to true.

If we cannot retrieve the posts, we throw an exception and `emit` `PostFailure()`.

If we can retrieve the posts, we return `PostSuccess()` which takes the entire list of posts.

One optimization we can make is to `debounce` the `Events` in order to prevent spamming our API unnecessarily. We can do this by overriding the `transform` method in our `PostBloc`.

?> **Note:** Passing a `transformer` to `on<PostFetched>` allows us to customize how events are processed.
?> **Note:** Make sure to import [`package:stream_transform`](https://pub.dev/packages/stream_transform) to use the `throttle` api.

[post_bloc_transformer.dart.dart](_snippets/flutter_infinite_list_tutorial/post_bloc_transformer.dart.md ':include')


Our finished `PostBloc` should now look like this:

[post_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_bloc.dart ':include')

Great! Now that we’ve finished implementing the business logic all that’s left to do is implement the presentation layer.

## Presentation Layer

In our `main.dart` we can start by implementing our main function and calling `runApp` to render our root widget. Here, we can also include our bloc observer to log transitions and any errors.

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/main.dart ':include')

?> **Note:** `EquatableConfig.stringify = kDebugMode;` is a constant that affects the output of toString. When in debug mode, equatable's toString method will behave differently than profile and release mode and can use constants like kDebugMode or kReleaseMode to understand if you are running on debug or release.

In our `App` widget, the root of our project, we can then set the home to `PostsPage`

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/app.dart ':include')

In our `PostsPage` widget, we use `BlocProvider` to create and provide an instance of `PostBloc` to the subtree. Also, we add a `PostFetched` event so that when the app loads, it requests the initial batch of Posts.

[posts_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/view/posts_page.dart ':include')

Next, we need to implement our `PostsList` view which will present our posts and hook up to our `PostBloc`.

[posts_list.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/view/posts_list.dart ':include')

?> `PostsList` is a `StatefulWidget` because it will need to maintain a `ScrollController`. In `initState`, we add a listener to our `ScrollController` so that we can respond to scroll events. We also access our `PostBloc` instance via `context.read<PostBloc>()`.

Moving along, our build method returns a `BlocBuilder`. `BlocBuilder` is a Flutter widget from the [flutter_bloc package](https://pub.dev/packages/flutter_bloc) which handles building a widget in response to new bloc states. Any time our `PostBloc` state changes, our builder function will be called with the new `PostState`.

!> We need to remember to clean up after ourselves and dispose of our `ScrollController` when the StatefulWidget is disposed.

Whenever the user scrolls, we calculate how far you have scrolled down the page and if our distance is ≥ 90% of our `maxScrollextent` we add a `PostFetched` event in order to load more posts.

Next, we need to implement our `BottomLoader` widget which will indicate to the user that we are loading more posts.

[bottom_loader.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/widgets/bottom_loader.dart ':include')

Lastly, we need to implement our `PostListItem` which will render an individual Post.

[post_list_item.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/widgets/post_list_item.dart ':include')

At this point, we should be able to run our app and everything should work; however, there’s one more thing we can do.

One added bonus of using the bloc library is that we can have access to all `Transitions` in one place.

> The change from one state to another is called a `Transition`.

?> A `Transition` consists of the current state, the event, and the next state.

Even though in this application we only have one bloc, it's fairly common in larger applications to have many blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocObserver`.

[simple_bloc_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/simple_bloc_observer.dart ':include')

?> All we need to do is extend `BlocObserver` and override the `onTransition` method.

Now every time a Bloc `Transition` occurs we can see the transition printed to the console.

?> In practice, you can create different `BlocObservers` and because every state change is recorded, we are able to very easily instrument our applications and track all user interactions and state changes in one place!

That’s all there is to it! We’ve now successfully implemented an infinite list in flutter using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) packages and we’ve successfully separated our presentation layer from our business logic.

Our `PostsPage` has no idea where the `Posts` are coming from or how they are being retrieved. Conversely, our `PostBloc` has no idea how the `State` is being rendered, it simply converts events into states.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
