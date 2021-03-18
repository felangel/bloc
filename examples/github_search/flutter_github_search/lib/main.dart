import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:flutter_github_search/search_form.dart';

void main() {
  final GithubRepository githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );

  runApp(App(githubRepository: githubRepository));
}

class App extends StatelessWidget {
  const App({Key? key, required this.githubRepository}) : super(key: key);

  final GithubRepository githubRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Search',
      home: Scaffold(
        appBar: AppBar(title: const Text('Github Search')),
        body: BlocProvider(
          create: (_) => GithubSearchBloc(githubRepository: githubRepository),
          child: SearchForm(),
        ),
      ),
    );
  }
}
