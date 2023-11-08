# مفاهیم اصلی (پکیج :bloc)

?> لطفاً قبل از کار با [package:bloc](https://pub.dev/packages/bloc) حتماً بخش‌های زیر را به دقت بخوانید.

چندین مفهوم اصلی وجود دارد که برای درک نحوه استفاده از بسته Bloc حیاتی است.

در بخش‌های جلوتر، می‌خواهیم هر یک از آنها را با جزئیات کامل مورد بحث قرار دهیم و همچنین نحوه اعمال آنها در یک برنامه شمارنده را بررسی کنیم.

## جریان‌ها (Streams)

?> برای اطلاعات بیشتر در مورد `جریان ها`، [داکیومنت رسمی دارت](https://dart.dev/tutorials/language/streams) را بررسی کنید.

> جریان مجموعه ای از داده های ناهمزمان است.

برای استفاده از کتابخانه Bloc، داشتن درک اولیه از `جریان‌ها` و نحوه کار آنها بسیار مهم است.

> اگر با جریان ها آشنا نیستید، کافی است به لوله‌ای فکر کنید که آب در آن جریان دارد. لوله، جریان (`Stream`) و آب، داده ناهمزمان (Asynchronous data) است.

ما می‌توانیم با نوشتن یک تابع `async*` (تولید کننده async) در Dart، یک جریان ایجاد کنیم.

[count_stream.dart](_snippets/core_concepts/count_stream.dart.md ':include')

با مشخص کردن یک تابع به‌عنوان `async*`، می‌توانیم از کلمه کلیدی `yield` استفاده کنیم و یک `Stream` از داده‌ها را برگردانیم. در مثال بالا، ما یک جریانی (`Stream`) از اعداد را تا پارامتر `max` برمی گردانیم.

هر بار که در یک تابع `async*`، عمل `yield` را انجام میدهیم، آن قطعه داده را از طریق `Stream` هل می‌دهیم.

ما می‌توانیم `Stream` فوق را به روش‌های مختلفی استفاده کنیم. اگر بخواهیم تابعی بنویسیم که مجموع یک `Stream` از اعداد را برگرداند، می تواند چیزی شبیه به زیر باشد:

[sum_stream.dart](_snippets/core_concepts/sum_stream.dart.md ':include')

با مشخص کردن تابع فوق به عنوان `async`، می توانیم از کلمه کلیدی `await` استفاده کرده و یک `Future` از اعداد صحیح را برگردانیم. در این مثال، ما منتظر هر مقدار در جریان هستیم و مجموع همه اعداد در جریان را برمی گردانیم.

ما می توانیم همه آن را به این صورت کنار هم بگذاریم:

[main.dart](_snippets/core_concepts/streams_main.dart.md ':include')

اکنون که درک اولیه ای از نحوه عملکرد `Streams` در Dart داریم، آماده هستیم تا در مورد هسته اصلی بسته Bloc بیاموزیم: یک `Cubit`.

## Cubit

> یک `Cubit` کلاسی است که از `BlocBase` ارث (extends) برده است و می تواند برای مدیریت هر نوع حالتی (State) گسترش یابد.

![Cubit Architecture](assets/cubit_architecture_full.png)

یک `Cubit` می‌تواند توابعی داشته باشد که با فراخوانی آن‌ها، تغییرات در وضعیت ایجاد شود.

> وضعیت ها (States) خروجی یک `Cubit` هستند و بخشی از وضعیت برنامه شما را، نشان می دهند. اجزای UI می توانند از وضعیت ها مطلع شوند و بخش هایی از خود را بر اساس وضعیت فعلی دوباره ترسیم کنند (وضعیت را تغییر دهند).

> **نکته**: برای کسب اطلاعات بیشتر در مورد ریشه `Cubit` [این Issue](https://github.com/felangel/cubit/issues/69) را بررسی کنید.

### ساخت یک Cubit

ما می‌توانیم یک `CounterCubit` ایجاد کنیم مانند:

[counter_cubit.dart](_snippets/core_concepts/counter_cubit.dart.md ':include')

هنگام ایجاد یک `Cubit`، باید نوع ,وضعیتی را که `Cubit` مدیریت خواهد کرد، تعریف کنیم. در مورد `CounterCubit` بالا، وضعیت را می‌توان از طریق `int` نشان داد، اما در موارد پیچیده‌تر ممکن است به جای یک داده‌ی اولیه(primitive type)، از `class` استفاده شود.

دومین کاری که باید هنگام ایجاد یک `Cubit` انجام دهیم، مشخص کردن حالت اولیه(Initial state) است. ما می توانیم این کار را با فراخوانی `super` با مقدار حالت اولیه انجام دهیم. در قطعه کد بالا(Snippet)، حالت اولیه را به صورت داخلی روی `0` تنظیم می‌کنیم، اما همچنین می‌توانیم با پذیرش یک مقدار خارجی، اجازه دهیم `Cubit` انعطاف‌پذیرتر باشد:

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_initial_state.dart.md ':include')

این به ما این امکان را می‌دهد که نمونه‌های `CounterCubit` را با وضعیت‌های اولیه(Initial states) متفاوت ایجاد کنیم، مانند:

[main.dart](_snippets/core_concepts/counter_cubit_instantiation.dart.md ':include')

### تغییرات وضعیت

> هر `Cubit` توانایی تولید وضعیت جدید را از طریق `emit` دارد.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_increment.dart.md ':include')

در تکه کد بالا، `CounterCubit` یک متد عمومی به نام `increment` را ارائه می‌دهد که می‌توان آن را از بیرون صدا زد تا `CounterCubit` را از افزایش وضعیت خود آگاه کند. وقتی `increment` فراخوانی می‌شود، می‌توانیم با استفاده از `state` برای دسترسی به وضعیت فعلی `Cubit` استفاده کرده و با اضافه کردن 1 به وضعیت فعلی، یک وضعیت جدید را با استفاده از `emit` اعلام کنیم.

!> متد `emit` محافظت شده(Protected) است، به این معنی که باید تنها در داخل یک `Cubit` استفاده شود.

### استفاده از یک Cubit 

اکنون می‌توانیم از `CounterCubit` که پیاده‌سازی کرده‌ایم، استفاده کنیم!

#### استفاده پایه(Basic)

[main.dart](_snippets/core_concepts/counter_cubit_basic_usage.dart.md ':include')

در تکه کد بالا، ما با شروع ایجاد یک نمونه از `CounterCubit` آغاز می‌کنیم. سپس وضعیت کنونی Cubit که وضعیت اولیه است (زیرا هیچ وضعیت جدیدی هنوز اعلام(Emit) نشده است) را چاپ می‌کنیم. در مرحله بعد، متد `increment` را فراخوانی می‌کنیم تا یک تغییر وضعیت را ایجاد کنیم. در پایان، وضعیت `Cubit` را دوباره چاپ می‌کنیم که از `0` به `1` تغییر کرده است، و متد `close` را بر روی `Cubit` صدا می‌زنیم(Call) تا Stream داخلی وضعیت بسته شود.

#### استفاده از جریان (Stream) 

`Cubit` یک `Stream` ارائه می‌دهد که به ما امکان می‌دهد تا به تغییرات وضعیت در لحظه دسترسی داشته باشیم.

[main.dart](_snippets/core_concepts/counter_cubit_stream_usage.dart.md ':include')

در تکه کد فوق، ما به `CounterCubit` مشترک(Subscribe) می‌شویم(به تغییراتش گوش میدهیم) و در هر تغییر وضعیت، `print` را صدا می‌زنیم. سپس، تابع `increment` را فراخوانی می‌کنیم که یک وضعیت جدید ارسال(Emit) خواهد کرد. در نهایت، وقتی دیگر نمی‌خواهیم به تغییرات گوش دهیم، دستور `cancel` را بر روی `subscription` اجرا کرده و `Cubit` را بسته می‌کنیم.

?> **توجه**: دستور `await Future.delayed(Duration.zero)` برای این مثال اضافه شده است تا از لغو اشتراک به صورت فوری جلوگیری شود.

!> تنها تغییرات وضعیت‌های بعدی در هنگام فراخوانی `listen` بر روی یک `Cubit` دریافت خواهد شد.

### مشاهده(Observing) یک Cubit

> وقتی یک `Cubit` وضعیت جدیدی را انتشار (Emit) می‌دهد، یک `Change` اتفاق می‌افتد. ما می‌توانیم تمام تغییراتی که برای یک `Cubit` خاص رخ می‌دهد را با بازنویسی(Override) متد `onChange` مشاهده کنیم.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_on_change.dart.md ':include')

سپس می‌توانیم با `Cubit` تعامل داشته باشیم و تمام تغییرات خروجی کنسول را مشاهده(Observe) کنیم.

[main.dart](_snippets/core_concepts/counter_cubit_on_change_usage.dart.md ':include')

مثال بالا خروجی می دهد:

[script](_snippets/core_concepts/counter_cubit_on_change_output.sh.md ':include')

?> **توجه**: یک `Change` درست قبل از به‌روزرسانی وضعیت `Cubit` رخ می‌دهد. یک `Change` از `currentState` و `nextState` تشکیل شده است.

#### BlocObserver

یک مزیت اضافی از استفاده از کتابخانه Bloc این است که می‌توانیم به تمام `Changes` در یک مکان دسترسی داشته باشیم. حتی اگر در این برنامه تنها یک `Cubit` داشته باشیم، در برنامه‌های بزرگ‌تر، داشتن تعداد زیادی `Cubits` که بخش‌های مختلف وضعیت برنامه را مدیریت می‌کنند، نسبتاً معمول است.

اگر می‌خواهیم بتوانیم کاری را در پاسخ به همه `Changes` انجام دهیم، می‌توانیم به سادگی `BlocObserver` خود را ایجاد کنیم.

[simple_bloc_observer_on_change.dart](_snippets/core_concepts/simple_bloc_observer_on_change.dart.md ':include')

?> **توجه**: تنها کاری که باید انجام دهیم این است که `BlocObserver` را گسترش داده (Extend کنید) و متد `onChange` را بازنویسی (Override) کنیم.

In order to use the `SimpleBlocObserver`, we just need to tweak the `main` function:

[main.dart](_snippets/core_concepts/simple_bloc_observer_on_change_usage.dart.md ':include')

The above snippet would then output:

[script](_snippets/core_concepts/counter_cubit_on_change_usage_output.sh.md ':include')

?> **Note**: The internal `onChange` override is called first, followed by `onChange` in `BlocObserver`.

?> 💡 **Tip**: In `BlocObserver` we have access to the `Cubit` instance in addition to the `Change` itself.

### Error Handling

> Every `Cubit` has an `addError` method which can be used to indicate that an error has occurred.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_on_error.dart.md ':include')

?> **Note**: `onError` can be overridden within the `Cubit` to handle all errors for a specific `Cubit`.

`onError` can also be overridden in `BlocObserver` to handle all reported errors globally.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_error.dart.md ':include')

If we run the same program again we should see the following output:

[script](_snippets/core_concepts/counter_cubit_on_error_output.sh.md ':include')

?> **Note**: Just as with `onChange`, the internal `onError` override is invoked before the global `BlocObserver` override.

## Bloc

> A `Bloc` is a more advanced class which relies on `events` to trigger `state` changes rather than functions. `Bloc` also extends `BlocBase` which means it has a similar public API as `Cubit`. However, rather than calling a `function` on a `Bloc` and directly emitting a new `state`, `Blocs` receive `events` and convert the incoming `events` into outgoing `states`.

![Bloc Architecture](assets/bloc_architecture_full.png)

### Creating a Bloc

Creating a `Bloc` is similar to creating a `Cubit` except in addition to defining the state that we'll be managing, we must also define the event that the `Bloc` will be able to process.

> Events are the input to a Bloc. They are commonly added in response to user interactions such as button presses or lifecycle events like page loads.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc.dart.md ':include')

Just like when creating the `CounterCubit`, we must specify an initial state by passing it to the superclass via `super`.

### State Changes

`Bloc` requires us to register event handlers via the `on<Event>` API, as opposed to functions in `Cubit`. An event handler is responsible for converting any incoming events into zero or more outgoing states.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_event_handler.dart.md ':include')

?> 💡 **Tip**: an `EventHandler` has access to the added event as well as an `Emitter` which can be used to emit zero or more states in response to the incoming event.

We can then update the `EventHandler` to handle the `CounterIncrementPressed` event:

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_increment.dart.md ':include')

In the above snippet, we have registered an `EventHandler` to manage all `CounterIncrementPressed` events. For each incoming `CounterIncrementPressed` event we can access the current state of the bloc via the `state` getter and `emit(state + 1)`.

?> **Note**: Since the `Bloc` class extends `BlocBase`, we have access to the current state of the bloc at any point in time via the `state` getter just like in `Cubit`.

!> Blocs should never directly `emit` new states. Instead every state change must be output in response to an incoming event within an `EventHandler`.

!> Both blocs and cubits will ignore duplicate states. If we emit `State nextState` where `state == nextState`, then no state change will occur.

### Using a Bloc

At this point, we can create an instance of our `CounterBloc` and put it to use!

#### Basic Usage

[main.dart](_snippets/core_concepts/counter_bloc_usage.dart.md ':include')

In the above snippet, we start by creating an instance of the `CounterBloc`. We then print the current state of the `Bloc` which is the initial state (since no new states have been emitted yet). Next, we add the `CounterIncrementPressed` event to trigger a state change. Finally, we print the state of the `Bloc` again which went from `0` to `1` and call `close` on the `Bloc` to close the internal state stream.

?> **Note**: `await Future.delayed(Duration.zero)` is added to ensure we wait for the next event-loop iteration (allowing the `EventHandler` to process the event).

#### Stream Usage

Just like with `Cubit`, a `Bloc` is a special type of `Stream`, which means we can also subscribe to a `Bloc` for real-time updates to its state:

[main.dart](_snippets/core_concepts/counter_bloc_stream_usage.dart.md ':include')

In the above snippet, we are subscribing to the `CounterBloc` and calling print on each state change. We are then adding the `CounterIncrementPressed` event which triggers the `on<CounterIncrementPressed>` `EventHandler` and emits a new state. Lastly, we are calling `cancel` on the subscription when we no longer want to receive updates and closing the `Bloc`.

?> **Note**: `await Future.delayed(Duration.zero)` is added for this example to avoid canceling the subscription immediately.

### Observing a Bloc

Since `Bloc` extends `BlocBase`, we can observe all state changes for a `Bloc` using `onChange`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_change.dart.md ':include')

We can then update `main.dart` to:

[main.dart](_snippets/core_concepts/counter_bloc_on_change_usage.dart.md ':include')

Now if we run the above snippet, the output will be:

[script](_snippets/core_concepts/counter_bloc_on_change_output.sh.md ':include')

One key differentiating factor between `Bloc` and `Cubit` is that because `Bloc` is event-driven, we are also able to capture information about what triggered the state change.

We can do this by overriding `onTransition`.

> The change from one state to another is called a `Transition`. A `Transition` consists of the current state, the event, and the next state.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

If we then rerun the same `main.dart` snippet from before, we should see the following output:

[script](_snippets/core_concepts/counter_bloc_on_transition_output.sh.md ':include')

?> **Note**: `onTransition` is invoked before `onChange` and contains the event which triggered the change from `currentState` to `nextState`.

#### BlocObserver

Just as before, we can override `onTransition` in a custom `BlocObserver` to observe all transitions that occur from a single place.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_transition.dart.md ':include')

We can initialize the `SimpleBlocObserver` just like before:

[main.dart](_snippets/core_concepts/simple_bloc_observer_on_transition_usage.dart.md ':include')

Now if we run the above snippet, the output should look like:

[script](_snippets/core_concepts/simple_bloc_observer_on_transition_output.sh.md ':include')

?> **Note**: `onTransition` is invoked first (local before global) followed by `onChange`.

Another unique feature of `Bloc` instances is that they allow us to override `onEvent` which is called whenever a new event is added to the `Bloc`. Just like with `onChange` and `onTransition`, `onEvent` can be overridden locally as well as globally.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_event.dart.md ':include')

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

We can run the same `main.dart` as before and should see the following output:

[script](_snippets/core_concepts/simple_bloc_observer_on_event_output.sh.md ':include')

?> **Note**: `onEvent` is called as soon as the event is added. The local `onEvent` is invoked before the global `onEvent` in `BlocObserver`.

### Error Handling

Just like with `Cubit`, each `Bloc` has an `addError` and `onError` method. We can indicate that an error has occurred by calling `addError` from anywhere inside our `Bloc`. We can then react to all errors by overriding `onError` just as with `Cubit`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

If we rerun the same `main.dart` as before, we can see what it looks like when an error is reported:

[script](_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **Note**: The local `onError` is invoked first followed by the global `onError` in `BlocObserver`.

?> **Note**: `onError` and `onChange` work the exact same way for both `Bloc` and `Cubit` instances.

!> Any unhandled exceptions that occur within an `EventHandler` are also reported to `onError`.

## Cubit vs. Bloc

Now that we've covered the basics of the `Cubit` and `Bloc` classes, you might be wondering when you should use `Cubit` and when you should use `Bloc`.

### Cubit Advantages

#### Simplicity

One of the biggest advantages of using `Cubit` is simplicity. When creating a `Cubit`, we only have to define the state as well as the functions which we want to expose to change the state. In comparison, when creating a `Bloc`, we have to define the states, events, and the `EventHandler` implementation. This makes `Cubit` easier to understand and there is less code involved.

Now let's take a look at the two counter implementations:

##### CounterCubit

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_full.dart.md ':include')

The `Cubit` implementation is more concise and instead of defining events separately, the functions act like events. In addition, when using a `Cubit`, we can simply call `emit` from anywhere in order to trigger a state change.

### Bloc Advantages

#### Traceability

One of the biggest advantages of using `Bloc` is knowing the sequence of state changes as well as exactly what triggered those changes. For state that is critical to the functionality of an application, it might be very beneficial to use a more event-driven approach in order to capture all events in addition to state changes.

A common use case might be managing `AuthenticationState`. For simplicity, let's say we can represent `AuthenticationState` via an `enum`:

[authentication_state.dart](_snippets/core_concepts/authentication_state.dart.md ':include')

There could be many reasons as to why the application's state could change from `authenticated` to `unauthenticated`. For example, the user might have tapped a logout button and requested to be signed out of the application. On the other hand, maybe the user's access token was revoked and they were forcefully logged out. When using `Bloc` we can clearly trace how the application state got to a certain state.

[script](_snippets/core_concepts/authentication_transition.sh.md ':include')

The above `Transition` gives us all the information we need to understand why the state changed. If we had used a `Cubit` to manage the `AuthenticationState`, our logs would look like:

[script](_snippets/core_concepts/authentication_change.sh.md ':include')

This tells us that the user was logged out but it doesn't explain why which might be critical to debugging and understanding how the state of the application is changing over time.

#### Advanced Event Transformations

Another area in which `Bloc` excels over `Cubit` is when we need to take advantage of reactive operators such as `buffer`, `debounceTime`, `throttle`, etc.

`Bloc` has an event sink that allows us to control and transform the incoming flow of events.

For example, if we were building a real-time search, we would probably want to debounce the requests to the backend in order to avoid getting rate-limited as well as to cut down on cost/load on the backend.

With `Bloc` we can provide a custom `EventTransformer` to change the way incoming events are processed by the `Bloc`.

[counter_bloc.dart](_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

With the above code, we can easily debounce the incoming events with very little additional code.

?> 💡 **Tip**: Check out [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) for an opinionated set of event transformers.

?> 💡 **Tip**: If you are still unsure about which to use, start with `Cubit` and you can later refactor or scale-up to a `Bloc` as needed.
