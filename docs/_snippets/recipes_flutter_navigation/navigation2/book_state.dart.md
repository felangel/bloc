```dart
class Book extends Equatable {
  const Book(this.title, this.author);

  final String title;
  final String author;

  @override
  List<Object> get props => [title, author];
}

const defaultBooks = <Book>[
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
    ValueGetter<Book?>? selectedBook,
    ValueGetter<List<Book>>? books,
  }) {
    return BookState(
      selectedBook: selectedBook != null ? selectedBook() : this.selectedBook,
      books: books != null ? books() : this.books,
    );
  }
}
```