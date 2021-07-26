```dart
part of 'book_bloc.dart';

@immutable
abstract class BookEvent extends Equatable {
  const BookEvent({this.book});

  final Book? book;

  @override
  List<Object> get props => [];
}

class BookSelected extends BookEvent {
  const BookSelected({required this.book});

  final Book book;

  @override
  List<Object> get props => [book];
}

class BackToList extends BookEvent {
  const BackToList();

  @override
  List<Object> get props => [];
}
```