```dart
import 'dart:async';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../main.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc() : super(BookInitial());

  @override
  Stream<BookState> mapEventToState(
    BookEvent event,
  ) async* {
    if (event is BookSelected) {
      yield SelectedBook(selectedBook: event.book);
    } else if (event is BackToList) {
      yield BookInitial();
    } else {
      yield BookInitial();
    }
  }
}
```