```dart
class AppRouter {
  final _counterBloc = CounterBloc();

  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _counterBloc,
            child: HomePage(),
          ),
        );
      case '/counter':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: _counterBloc,
            child: CounterPage(),
          ),
        );
      default:
        return null;
    }
  }

  void dispose() {
    _counterBloc.close();
  }
}
```
