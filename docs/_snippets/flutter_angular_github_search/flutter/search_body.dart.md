```dart
class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchStateEmpty() => const Text('Please enter a term to begin'),
          SearchStateLoading() => const CircularProgressIndicator(),
          SearchStateError() => Text(state.error),
          SearchStateSuccess() => state.items.isEmpty
              ? const Text('No Results')
              : Expanded(child: _SearchResults(items: state.items)),
        };
      },
    );
  }
}
```
