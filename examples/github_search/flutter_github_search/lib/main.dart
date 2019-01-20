import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:common_github_search/common_github_search.dart';

void main() => runApp(SearchApp());

class SearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Search',
      home: Scaffold(
        appBar: AppBar(title: Text("Github Search")),
        body: SearchForm(),
      ),
    );
  }
}

// Define a Custom Form Widget
class SearchForm extends StatefulWidget {
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _textController = TextEditingController();

  final GithubSearchBloc _githubSearchBloc = GithubSearchBloc(
    GithubService(
      GithubCache(),
      GithubClient(http.Client()),
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _githubSearchBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _textController,
          autocorrect: false,
          onChanged: (text) {
            _githubSearchBloc.dispatch(
              TextChanged(text: text),
            );
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter a search term',
          ),
        ),
        BlocBuilder<GithubSearchEvent, GithubSearchState>(
          bloc: _githubSearchBloc,
          builder: (BuildContext context, GithubSearchState state) {
            if (state is SearchStateEmpty) {
              return Text("Please enter a term to begin");
            }

            if (state is SearchStateLoading) {
              return CircularProgressIndicator();
            }

            if (state is SearchStateError) {
              return Text("Error: Rate Limit Exceeded");
            }

            if (state is SearchStateSuccess) {
              return state.items.isEmpty
                  ? Text("No Results")
                  : Expanded(child: SearchResults(items: state.items));
            }
          },
        )
      ],
    );
  }
}

class SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return SearchResultItemWidget(item: items[index]);
      },
    );
  }
}

class SearchResultItemWidget extends StatelessWidget {
  final SearchResultItem item;

  const SearchResultItemWidget({Key key, @required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
    );
  }
}
