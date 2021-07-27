```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc() : super(BookState());

  @override
  Stream<BookState> mapEventToState(
    BookEvent event,
  ) async* {
    if (event is BookSelected) {
      yield state.copyWith(selectedBook: event.book);
    } else if (event is BookDeselected) {
      yield BookState(books: state.books);
    }
  }
}
```