# Flutter Infinite List Tutorial

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> In this tutorial, we’re going to be implementing an app which fetches data over the network and loads it as a user scrolls using Flutter and the bloc library.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Setup

We’ll start off by creating a brand new Flutter project

[script](../_snippets/flutter_infinite_list_tutorial/flutter_create.sh.md ':include')

We can then go ahead and replace the contents of pubspec.yaml with

[pubspec.yaml](../_snippets/flutter_infinite_list_tutorial/pubspec.yaml.md ':include')

and then install all of our dependencies

[script](../_snippets/flutter_infinite_list_tutorial/flutter_packages_get.sh.md ':include')

## REST API

For this demo application, we’ll be using [jsonplaceholder](http://jsonplaceholder.typicode.com) as our data source.

?> jsonplaceholder is an online REST API which serves fake data; it’s very useful for building prototypes.

Open a new tab in your browser and visit https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 to see what the API returns.

[posts.json](../_snippets/flutter_infinite_list_tutorial/posts.json.md ':include')

?> **Note:** in our url we specified the start and limit as query parameters to the GET request.

Great, now that we know what our data is going to look like, let’s create the model.

## Data Model

Create `post.dart` and let’s get to work creating the model of our Post object.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post.dart.md ':include')

`Post` is just a class with an `id`, `title`, and `body`.

?> We override the `toString` function in order to have a custom string representation of our `Post` for later.

?> We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare `Posts`; by default, the equality operator returns true if and only if this and other are the same instance.

Now that we have our `Post` object model, let’s start working on the Business Logic Component (bloc).

## Post Events

Before we dive into the implementation, we need to define what our `PostBloc` is going to be doing.

At a high level, it will be responding to user input (scrolling) and fetching more posts in order for the presentation layer to display them. Let’s start by creating our `Event`.

Our `PostBloc` will only be responding to a single event; `PostFetched` which will be added by the presentation layer whenever it needs more Posts to present. Since our `PostFetched` event is a type of `PostEvent` we can create `bloc/post_event.dart` and implement the event like so.

[post_event.dart](../_snippets/flutter_infinite_list_tutorial/post_event.dart.md ':include')

To recap, our `PostBloc` will be receiving `PostEvents` and converting them to `PostStates`. We have defined all of our `PostEvents` (PostFetched) so next let’s define our `PostState`.

## Post States

Our presentation layer will need to have several pieces of information in order to properly lay itself out:

- `PostInitial`- will tell the presentation layer it needs to render a loading indicator while the initial batch of posts are loaded

- `PostSuccess`- will tell the presentation layer it has content to render
  - `posts`- will be the `List<Post>` which will be displayed
  - `hasReachedMax`- will tell the presentation layer whether or not it has reached the maximum number of posts
- `PostFailure`- will tell the presentation layer that an error has occurred while fetching posts

We can now create `bloc/post_state.dart` and implement it like so.

[post_state.dart](../_snippets/flutter_infinite_list_tutorial/post_state.dart.md ':include')

?> We implemented `copyWith` so that we can copy an instance of `PostSuccess` and update zero or more properties conveniently (this will come in handy later ).

Now that we have our `Events` and `States` implemented, we can create our `PostBloc`.

To make it convenient to import our states and events with a single import we can create `bloc/bloc.dart` which exports them all (we'll add our `post_bloc.dart` export in the next section).

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc_initial.dart.md ':include')

## Post Bloc

For simplicity, our `PostBloc` will have a direct dependency on an `http client`; however, in a production application you might want instead inject an api client and use the repository pattern [docs](./architecture.md).

Let’s create `post_bloc.dart` and create our empty `PostBloc`.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial.dart.md ':include')

?> **Note:** just from the class declaration we can tell that our PostBloc will be taking PostEvents as input and outputting PostStates.

We can start by implementing `initialState` which will be the state of our `PostBloc` before any events have been added.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial_state.dart.md ':include')

Next, we need to implement `mapEventToState` which will be fired every time a `PostEvent` is added.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_map_event_to_state.dart.md ':include')

Our `PostBloc` will `yield` whenever there is a new state because it returns a `Stream<PostState>`. Check out [core concepts](https://bloclibrary.dev/#/coreconcepts?id=streams) for more information about `Streams` and other core concepts.

Now every time a `PostEvent` is added, if it is a `PostFetched` event and there are more posts to fetch, our `PostBloc` will fetch the next 20 posts.

The API will return an empty array if we try to fetch beyond the maximum number of posts (100), so if we get back an empty array, our bloc will `yield` the currentState except we will set `hasReachedMax` to true.

If we cannot retrieve the posts, we throw an exception and `yield` `PostFailure()`.

If we can retrieve the posts, we return `PostSuccess()` which takes the entire list of posts.

One optimization we can make is to `debounce` the `Events` in order to prevent spamming our API unnecessarily. We can do this by overriding the `transform` method in our `PostBloc`.

?> **Note:** Overriding transform allows us to transform the Stream<Event> before mapEventToState is called. This allows for operations like distinct(), debounceTime(), etc... to be applied.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_transform_events.dart.md ':include')

Our finished `PostBloc` should now look like this:

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc.dart.md ':include')

Don't forget to update `bloc/bloc.dart` to include our `PostBloc`!

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc.dart.md ':include')

Great! Now that we’ve finished implementing the business logic all that’s left to do is implement the presentation layer.

## Presentation Layer

In our `main.dart` we can start by implementing our main function and calling `runApp` to render our root widget.

In our `App` widget, we use `BlocProvider` to create and provide an instance of `PostBloc` to the subtree. Also, we add a `PostFetched` event so that when the app loads, it requests the initial batch of Posts.

[main.dart](../_snippets/flutter_infinite_list_tutorial/main.dart.md ':include')

Next, we need to implement our `HomePage` widget which will present our posts and hook up to our `PostBloc`.

[home_page.dart](../_snippets/flutter_infinite_list_tutorial/home_page.dart.md ':include')

?> `HomePage` is a `StatefulWidget` because it will need to maintain a `ScrollController`. In `initState`, we add a listener to our `ScrollController` so that we can respond to scroll events. We also access our `PostBloc` instance via `BlocProvider.of<PostBloc>(context)`.

Moving along, our build method returns a `BlocBuilder`. `BlocBuilder` is a Flutter widget from the [flutter_bloc package](https://pub.dev/packages/flutter_bloc) which handles building a widget in response to new bloc states. Any time our `PostBloc` state changes, our builder function will be called with the new `PostState`.

!> We need to remember to clean up after ourselves and dispose of our `ScrollController` when the StatefulWidget is disposed.

Whenever the user scrolls, we calculate how far away from the bottom of the page they are and if the distance is ≤ our `_scrollThreshold` we add a `PostFetched` event in order to load more posts.

Next, we need to implement our `BottomLoader` widget which will indicate to the user that we are loading more posts.

[bottom_loader.dart](../_snippets/flutter_infinite_list_tutorial/bottom_loader.dart.md ':include')

Lastly, we need to implement our `PostWidget` which will render an individual Post.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post_widget.dart.md ':include')

At this point, we should be able to run our app and everything should work; however, there’s one more thing we can do.

One added bonus of using the bloc library is that we can have access to all `Transitions` in one place.

> The change from one state to another is called a `Transition`.

?> A `Transition` consists of the current state, the event, and the next state.

Even though in this application we only have one bloc, it's fairly common in larger applications to have many blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocDelegate`.

[simple_bloc_delegate.dart](../_snippets/flutter_infinite_list_tutorial/simple_bloc_delegate.dart.md ':include')

?> All we need to do is extend `BlocDelegate` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocDelegate`, we just need to tweak our main function.

[main.dart](../_snippets/flutter_infinite_list_tutorial/bloc_delegate_main.dart.md ':include')

Now when we run our application, every time a Bloc `Transition` occurs we can see the transition printed to the console.

?> In practice, you can create different `BlocDelegates` and because every state change is recorded, we are able to very easily instrument our applications and track all user interactions and state changes in one place!

That’s all there is to it! We’ve now successfully implemented an infinite list in flutter using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) packages and we’ve successfully separated our presentation layer from our business logic.

Our `HomePage` has no idea where the `Posts` are coming from or how they are being retrieved. Conversely, our `PostBloc` has no idea how the `State` is being rendered, it simply converts events into states.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
