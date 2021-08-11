```dart
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/book_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => BookBloc(),
      child: BooksApp(),
    ),
  );
}

List<Page> onGeneratePages(BookState state, List<Page> pages) {
  final selectedBook = state.selectedBook;
  return [
    BooksListPage(books: state.books).page(),
    if (selectedBook != null) BookDetailsPage(book: selectedBook).page()
  ];
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: FlowBuilder(
        state: context.watch<BookBloc>().state,
        onGeneratePages: onGeneratePages,
      ),
    );
  }
}

class BooksListPage extends StatelessWidget {
  Page page() => MaterialPage<void>(
          child: BooksListPage(
        books: books,
      ),);

  final List<Book> books;

  const BooksListPage({
    Key? key,
    required this.books,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (final book in books)
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

class BookDetailsPage extends StatelessWidget {
  Page page() => MaterialPage<void>(
          child: BookDetailsPage(
        book: book,
      ),);

  final Book book;

  const BookDetailsPage({
    Key? key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: theme.textTheme.headline6),
            Text(book.author, style: theme.textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
```
