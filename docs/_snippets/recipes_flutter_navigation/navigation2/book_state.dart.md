```dart
part of 'book_bloc.dart';

@immutable
abstract class BookState {
  const BookState({this.selectedBook});

  final Book? selectedBook;
}

class BookInitial extends BookState {
  const BookInitial() : super(selectedBook: null);
}

class SelectedBook extends BookState {
  const SelectedBook({required this.selectedBook})
      : super(selectedBook: selectedBook);

  final Book selectedBook;
}
```