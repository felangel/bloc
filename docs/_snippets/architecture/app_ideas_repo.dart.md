```dart
class AppIdeasRepository {
  int _currentAppIdea = 0;
  final List<String> _ideas = [
    "Future prediction app that rewards you if you predict the next day's news",
    'Dating app for fish that lets your aquarium occupants find true love',
    'Social media app that pays you when your data is sold',
    'JavaScript framework gambling app that lets you bet on the next big thing',
    'Solitaire app that freezes before you can win',
  ];

  Stream<String> productIdeas() async* {
    while (true) {
      yield _ideas[_currentAppIdea++ % _ideas.length];
      await Future<void>.delayed(const Duration(minutes: 1));
    }
  }
}
```
