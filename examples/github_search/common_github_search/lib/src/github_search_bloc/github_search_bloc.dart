import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:stream_transform/stream_transform.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  GithubSearchBloc({required this._githubRepository})
    : super(SearchStateEmpty()) {
    on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
    // droppable: ignore new page requests while one is already in flight.
    on<NextPageRequested>(_onNextPage, transformer: droppable());
    // restartable: newest refresh wins; resets to page 1.
    on<Refreshed>(_onRefreshed, transformer: restartable());
  }

  final GithubRepository _githubRepository;

  // ponytail: observability for the concurrency behavior — shows in the browser
  // console under `[GithubSearchBloc]`. Uses dart:developer.log (avoid_print).
  void _log(String message) => developer.log(message, name: 'GithubSearchBloc');

  // ponytail: monotonic race-guard stamp. Per-handler transformers are
  // INDEPENDENT — restartable() on Refreshed cancels only the Refreshed
  // handler's own future, NOT a droppable _onNextPage already awaiting. So a
  // slow next page can resolve after a refresh/new search and clobber results.
  // Every fresh search bumps this; _onNextPage drops its result if the stamp
  // moved while it awaited. Also catches a same-term refresh, which a
  // searchTerm-only guard would miss.
  var _generation = 0;

  Future<void> _onTextChanged(
    TextChanged event,
    Emitter<GithubSearchState> emit,
  ) async {
    final searchTerm = event.text;

    if (searchTerm.isEmpty) return emit(SearchStateEmpty());

    final generation = ++_generation;
    _log('search "$searchTerm" g$generation (debounce) p1');
    emit(SearchStateLoading());

    try {
      final result = await _githubRepository.search(searchTerm);
      _log('search "$searchTerm" g$generation: ${result.items.length} items');
      emit(
        SearchStateSuccess(
          items: result.items,
          searchTerm: searchTerm,
          page: 1,
          hasReachedMax: _reachedMax(result.items.length, result),
          generation: generation,
        ),
      );
    } catch (error) {
      emit(_errorState(error));
    }
  }

  Future<void> _onRefreshed(
    Refreshed event,
    Emitter<GithubSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchStateSuccess) {
      _log('Refreshed ignored — no active search');
      return;
    }
    final searchTerm = currentState.searchTerm;
    final generation = ++_generation;
    _log('refresh "$searchTerm" g$generation (restartable) p1');

    // ponytail: no full-screen SearchStateLoading — RefreshIndicator shows its
    // own spinner; just emit the new Success (or an error) when data arrives.
    try {
      final result = await _githubRepository.search(
        searchTerm,
        forceRefresh: true,
      );
      emit(
        SearchStateSuccess(
          items: result.items,
          searchTerm: searchTerm,
          page: 1,
          hasReachedMax: _reachedMax(result.items.length, result),
          generation: generation,
        ),
      );
    } catch (error) {
      emit(_errorState(error));
    }
  }

  Future<void> _onNextPage(
    NextPageRequested event,
    Emitter<GithubSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchStateSuccess || currentState.hasReachedMax) {
      _log('NextPageRequested ignored — no results or hasReachedMax');
      return;
    }
    final searchTerm = currentState.searchTerm;
    final generation = currentState.generation; // capture BEFORE await
    final nextPage = currentState.page + 1;
    _log('nextPage "$searchTerm" g$generation → p$nextPage (droppable)');

    try {
      final result = await _githubRepository.search(searchTerm, page: nextPage);
      // ponytail: droppable only serialises NextPage against itself. A
      // Refreshed/TextChanged (restartable/debounce) can replace state while
      // this page is in flight and resolve first. Drop the stale page unless
      // the same generation is still current.
      final latest = state;
      if (latest is! SearchStateSuccess || latest.generation != generation) {
        final currentGen = latest is SearchStateSuccess
            ? '${latest.generation}'
            : 'n/a';
        _log('DROPPED stale p$nextPage g$generation ≠ current g$currentGen');
        return;
      }
      final merged = [...latest.items, ...result.items];
      _log('p$nextPage merged → ${merged.length} items g$generation');
      emit(
        SearchStateSuccess(
          items: merged,
          searchTerm: searchTerm,
          page: nextPage,
          hasReachedMax: _reachedMax(merged.length, result),
          generation: generation,
        ),
      );
    } catch (error) {
      emit(_errorState(error));
    }
  }

  bool _reachedMax(int accumulatedCount, SearchResult result) =>
      result.items.isEmpty || accumulatedCount >= result.totalCount;
  // ponytail: GitHub caps search results at 1000; totalCount can exceed that.
  // Fine for an example.

  GithubSearchState _errorState(Object error) => error is SearchResultError
      ? SearchStateError(error.message)
      : const SearchStateError('something went wrong');
}
