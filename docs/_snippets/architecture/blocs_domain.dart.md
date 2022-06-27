```dart
class AppIdeaRankingBloc
    extends Bloc<AppIdeaRankingEvent, AppIdeaRankingState> {
  AppIdeaRankingBloc({required AppIdeasRepository appIdeasRepo})
      : _appIdeasRepo = appIdeasRepo,
        super(AppIdeaInitialRankingState()) {
    on<AppIdeaStartRankingEvent>((event, emit) async {
      // When we are told to start ranking app ideas, we will listen to the
      // stream of app ideas and emit a state for each one.
      await emit.forEach(
        _appIdeasRepo.productIdeas(),
        onData: (String idea) => AppIdeaRankingIdeaState(idea: idea),
      );
    });
  }

  final AppIdeasRepository _appIdeasRepo;
}
```
