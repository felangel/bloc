# todos_repository

An app-agnostic data source that can be used by sample apps to fetch and persist data.

## Key Concepts

  * Defines *what* can be fetched from the data layer
  * Does not expose *how* the data is fetched and stored
  * Should be consumed by the domain layer

## Defines *what* can be fetched from the data layer

The goal of the repository pattern is to provide an abstract interface to the data layer of your application. The Repository describes the entities that can be fetched and stored, but should not expose how those things happen.

The term "Data Layer" comes from the "Clean Architecture Pattern." In this pattern, we separate our app into layers. Each Layer should only talk to the layer after it.

   * Presentation Layer -- Flutter Widgets or Angular Apps! Is given data from the Domain Layer and converts it into a UI. Tested with something like `flutter_test`.
   * Domain Layer -- How we manage App State changes and communicate those to the data layer. Can generally be written and tested as a pure Dart code.
   * Data layer -- Provides a single interface to the storage mechanisms.

## Does not expose *how* the data is fetched and stored

This library does not expose the in-memory, web client, or file storage mechanisms directly, but describes what an interface the domain layer can work with.

Concrete implementations, such as `todos_repository_simple`, provide the actual mechanism for storing and retrieving data for the appropriate environment.

This separation provides several benefits:

  * We could change the underlying storage mechanism without requiring any of of the apps to change.
  * We can control the the fallback logic in a central place. E.g. We first try to read todos from memory, then from disk, then from the web. We can always change the way this works in the concrete implementation.
  * We can compose several different data sources together into a single, easy-to-consume Entity.

## Should be consumed by the domain layer

In order to maximize code sharing, the domain layer should be pure Dart and depend on the abstract classes defined in this library rather than concrete implementations. This allows the domain layer to be shared across different environments, such as Flutter and Web.
