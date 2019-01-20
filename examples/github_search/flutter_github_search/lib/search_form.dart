import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatefulWidget {
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final GithubSearchBloc _githubSearchBloc = GithubSearchBloc(
    GithubRepository(
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
        _SearchBar(githubSearchBloc: _githubSearchBloc),
        _SearchBody(githubSearchBloc: _githubSearchBloc)
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  final GithubSearchBloc githubSearchBloc;

  _SearchBar({Key key, this.githubSearchBloc}) : super(key: key);

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();

  GithubSearchBloc get githubSearchBloc => widget.githubSearchBloc;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        githubSearchBloc.dispatch(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.close),
          onTap: _onCloseTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onCloseTapped() {
    _textController.text = '';
    githubSearchBloc.dispatch(TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  final GithubSearchBloc githubSearchBloc;

  const _SearchBody({Key key, this.githubSearchBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchEvent, GithubSearchState>(
      bloc: githubSearchBloc,
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text('Error: Rate Limit Exceeded');
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItemWidget(item: items[index]);
      },
    );
  }
}

class _SearchResultItemWidget extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItemWidget({Key key, @required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
