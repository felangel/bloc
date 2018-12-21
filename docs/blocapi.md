# Bloc API Reference

## Bloc<Event, State>

Takes a `Stream` of `Events` as input and transforms them into a `Stream` of `States` as output.

### Properties

**`currentState -> State`**

Returns the current `State` of the Bloc. (read-only)

---

**`initialState -> State`**

Returns the `State` before any `Events` have been dispatched.

---

**`state → Stream<State>`**

Returns `Stream` of `States`.

---

### Methods

**`dispatch(Event event) → void`**

Takes an `Event` and triggers `mapEventToState`. `Dispatch` may be called from the presentation layer or from within the Bloc. `Dispatch` notifies the Bloc of a new `Event`.

---

**`dispose() → void`**

Closes the Event and State Streams.

---

**`mapEventToState(State currentState, Event event) → Stream<State>`**

Must be implemented when a class extends Bloc. Takes the current state and incoming event as arguments. `mapEventToState` is called whenever an `Event` is dispatched by the presentation layer. `mapEventToState` must convert that `Event`, along with the current `State`, into a new `State` and return the new `State` in the form of a `Stream`.

---

**`onTransition(Transition<Event, State> transition) → void`**

Called whenever a `Transition` occurs with the given `Transition`. A `Transition` occurs when a new `Event` is `dispatched` and `mapEventToState` executed. `onTransition` is called just before a Bloc's `State` has been updated. _A great spot to add logging/analytics_.

---

**`transform(Stream<Event> events) → Stream<Event>`**

`Transform` the `Stream<Event>` before `mapEventToState` is called. This allows for operations like `distinct()`, `debounce()`, etc... to be applied.

---

## BlocDelegate

Handles `Events` from all `Blocs` which are delegated by the `BlocSupervisor`.

### Methods

**`onTransition(Transition transition) → void`**

Called whenever a `Transition` occurs with the given `Transition` in any Bloc. A `Transition` occurs when a new `Event` is dispatched and `mapEventToState` executed. `onTransition` is called just before a Bloc's `state` has been updated. _A great spot to add universal logging/analytics._

---

## BlocSupervisor

Oversees all `Blocs` and delegates responsibilities to the `BlocDelegate`.

### Properties

**`delegate ↔ BlocDelegate`**

`BlocDelegate` which is notified when events occur in all Blocs.

---

## Transition

Occurs when an `Event` is dispatched after `mapEventToState` has been called but before the Bloc's `State` has been updated. A `Transition` consists of the currentState, the event which was dispatched, and the nextState.

### Properties

**`currentState → State`**

---

**`event → Event`**

---

**`nextState → State`**

---
