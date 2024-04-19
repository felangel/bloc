enum HomeTab { todos, stats }

class HomeState {
  const HomeState({this.tab = HomeTab.todos});

  final HomeTab tab;

  HomeState copyWith({HomeTab? tab}) => HomeState(tab: tab ?? this.tab);
}
