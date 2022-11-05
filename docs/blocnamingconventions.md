# Naming Conventions

!> The following naming conventions are simply recommendations and are completely optional. Feel free to use whatever naming conventions you prefer. You may find some of the examples/documentation do not follow the naming conventions mainly for simplicity/conciseness. These conventions are strongly recommended for large projects with multiple developers.

## Event Conventions

> Events should be named in the **past tense** because events are things that have already occurred from the bloc's perspective.

### Anatomy

[event](_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Initial load events should follow the convention: `BlocSubject` + `Started`

!> The base event class should be name: `BlocSubject` + `Event`.

#### Examples

✅ **Good**

[events_good](_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Bad**

[events_bad](_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## State Conventions

> States should be nouns because a state is just a snapshot at a particular point in time. There are two common ways to represent state: using subclasses or using a single class.

### Anatomy

#### Subclasses

[state](_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> When representing the state as multiple subclasses `State` should be one of the following: `Initial` | `Success` | `Failure` | `InProgress` and initial states should follow the convention: `BlocSubject` + `Initial`.

#### Single Class

[state](_snippets/bloc_naming_conventions/single_state_anatomy.md ':include')

?> When representing the state as a single base class an enum named `BlocSubject` + `Status` should be used to represent the status of the state: `initial` | `success` | `failure` | `loading`.

!> The base state class should always be named: `BlocSubject` + `State`.

#### Examples

✅ **Good**

##### Subclasses

[states_good](_snippets/bloc_naming_conventions/state_examples_good.md ':include')

##### Single Class

[states_good](_snippets/bloc_naming_conventions/single_state_examples_good.md ':include')

❌ **Bad**

[states_bad](_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
