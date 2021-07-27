```dart
part of 'book_bloc.dart';

class Book extends Equatable {
  final String title;
  final String author;

  const Book(this.title, this.author);

  @override
  List<Object> get props => [title, author];
}

const List<Book> defaultBooks = [
  Book('Left Hand of Darkness', 'Ursula K. Le Guin'),
  Book('Too Like the Lightning', 'Ada Palmer'),
  Book('Kindred', 'Octavia E. Butler'),
];

class BookState extends Equatable {
  const BookState({this.selectedBook, this.books = defaultBooks});

  final Book? selectedBook;
  final List<Book> books;

  @override
  List<Object?> get props => [selectedBook, books];

  BookState copyWith({
    Book? selectedBook,
    List<Book>? books,
  }) {
    return BookState(
      selectedBook: selectedBook ?? this.selectedBook,
      books: books ?? this.books,
    );
  }
}
```