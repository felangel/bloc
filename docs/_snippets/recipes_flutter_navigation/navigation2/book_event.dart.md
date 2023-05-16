```dart
sealed class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

final class BookSelected extends BookEvent {
  const BookSelected({required this.book});

  final Book book;

  @override
  List<Object> get props => [book];
}

final class BookDeselected extends BookEvent {
  const BookDeselected();
}
```
