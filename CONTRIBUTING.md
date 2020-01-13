# Contributing to Bloc

👍🎉 First off, thanks for taking the time to contribute! 🎉👍

The following is a set of guidelines for contributing to Bloc and its packages.
These are mostly guidelines, not rules. Use your best judgment,
and feel free to propose changes to this document in a pull request.

## Proposing a Change

If you intend to change the public API, or make any non-trivial changes
to the implementation, we recommend filing an issue.
This lets us reach an agreement on your proposal before you put significant
effort into it.

If you’re only fixing a bug, it’s fine to submit a pull request right away
but we still recommend to file an issue detailing what you’re fixing.
This is helpful in case we don’t accept that specific fix but want to keep
track of the issue.

## Creating a Pull Request

Before creating a pull request please:

1. Fork the repository and create your branch from `master`.
1. Install all dependencies (`flutter packages get` or `pub get`).
1. Squash your commits and ensure you have a meaningful commit message.
1. If you’ve fixed a bug or added code that should be tested, add tests!
Pull Requests without 100% test coverage will not be approved.
1. Ensure the test suite passes.
1. If you've changed the public API, make sure to update/add documentation.
1. Format your code (`dartfmt -w .`).
1. Analyze your code (`dartanalyzer --fatal-infos --fatal-warnings .`).
1. Create the Pull Request.
1. Verify that all status checks are passing.

While the prerequisites above must be satisfied prior to having your
pull request reviewed, the reviewer(s) may ask you to complete additional
design work, tests, or other changes before your pull request can be ultimately
accepted.

## Contributing to Documentation

If you would like to contribute to the [documentation](https://bloclibrary.dev)
please follow the same process for "Creating a Pull Request" and double check
that your changes look good by running the docs locally.

```sh
# change directories into docs
cd ./docs

# run a local http server on port 8080
python -m SimpleHTTPServer 8080 .

# navigate to http://localhost:8080
```

To make PRs more readable, please provide this checklist to the PR description
so other contributors can easily see what's already done.

```text
- [ ] README
- [ ] Cover page
- [ ] Sidebar
- Introduction
  - [ ] Getting Started
  - [ ] Why Bloc?
- Core Concepts
  - [ ] bloc
  - [ ] flutter_bloc
- [ ] Architecture
- [ ] Testing
- [ ] Naming Conventions
- Tutorials
  - Flutter
    - [ ] Counter
    - [ ] Timer
    - [ ] Infinite List
    - [ ] Login
    - [ ] Weather
    - [ ] Todos
    - [ ] Firebase Login
    - [ ] Firestore Todos
  - AngularDart
    - [ ] Counter
  - Flutter + AngularDart
    - [ ] Github Search
- Recipes
  - Flutter
    - [ ] Show SnackBar
    - [ ] Navigation
    - [ ] Bloc Access
- Tools
  - Extensions
    - [ ] IntelliJ
    - [ ] VSCode
```

## Getting in Touch

If you want to just ask a question or get feedback on an idea you can post it
on [Discord](https://discord.gg/Hc5KD3g).

## License

By contributing to Bloc, you agree that your contributions will be licensed
under its MIT license.
