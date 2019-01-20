import 'package:flutter/material.dart';

import 'package:flutter_github_search/search_form.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Search',
      home: Scaffold(
        appBar: AppBar(title: Text('Github Search')),
        body: SearchForm(),
      ),
    );
  }
}
