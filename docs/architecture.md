# Architecture

> A Bloc takes a stream of events as input and transforms them into a stream of states as output.

In order to understand how a Bloc works, we'll take the example of a Timer application.

We can split the timer application into two parts:
- UI (user interface)
- Logic

For the sake of simplicity, our UI will be extremely simple: we're just going to print to the console.

Regarding the logic, we're going to need to make a 