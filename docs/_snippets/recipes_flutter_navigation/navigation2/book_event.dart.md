```dart
part of 'book_bloc.dart';

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

class BookDeselected extends BookEvent {
  const BookDeselected();

  @override
  List<Object> get props => [];
}
```