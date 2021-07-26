```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/book_bloc.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();

  runApp(
    BlocProvider(
      create: (context) => BookBloc(),
      child: BooksApp(),
    ),
  );
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatelessWidget {
  final List<Book> books = [
    Book('Left Hand of Darkness', 'Ursula K. Le Guin'),
    Book('Too Like the Lightning', 'Ada Palmer'),
    Book('Kindred', 'Octavia E. Butler'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          return Navigator(
            pages: [
              MaterialPage(
                key: ValueKey('BooksListPage'),
                child: BooksListScreen(
                  books: books,
                ),
              ),
              if (state is SelectedBook)
                MaterialPage(
                    key: ValueKey(state.selectedBook),
                    child: BookDetailsScreen(book: state.selectedBook))
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }

              BlocProvider.of<BookBloc>(context).add(BackToList());

              return true;
            },
          );
        },
      ),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  BooksListScreen({
    required this.books,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => context.read<BookBloc>().add(
                    BookSelected(book: book),
                  ),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
```