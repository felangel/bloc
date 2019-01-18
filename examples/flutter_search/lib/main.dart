import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './models/entities.dart';
import './github_service/github_service.dart';

void main() => runApp(SearchApp());

class SearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search for articles',
      home: Scaffold(
        appBar: AppBar(title: Text("Enter a search term")),
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

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _SearchFormState extends State<SearchForm> {
  //final items = List<String>.generate(10000, (i) => "Item $i");
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final _textController = TextEditingController();

  final GithubSearchBloc _githubSearchBloc = GithubSearchBloc(
      GithubService(GithubCache(), GithubClient(http.Client())));

  @override
  void initState() {
    _githubSearchBloc.dispatch(TextChanged(text: ""));

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    _githubSearchBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchEvent, GithubSearchState>(
      bloc: _githubSearchBloc,
      builder: (BuildContext context, GithubSearchState state) {
        if (!state.noTerm) {
          print(state.noTerm);
        }
        return Column(
          children: <Widget>[
            Padding(
              padding: new EdgeInsets.only(top: 20.0),
            ),
            TextField(
              controller: _textController,
              onChanged: (text) {
                _githubSearchBloc.dispatch(TextChanged(text: text));
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Please enter a search term'),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: state.result.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    print("From widget ${state.result.items[index].full_name}");
                    return ListTile(
                      title: Text("${state.result.items[index].full_name}"),
                    );
                  }),
            )
          ],
        );
      },
    );
  }

  Widget _buildTextFieldChild({Widget child, TextField textField}) {
    Widget textFieldAndChild = Row(
      children: <Widget>[textField, child],
    );
    return textFieldAndChild;
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
        child: Image.network("$item?.owner.avatar_url"),
      ),
      title: Text("$item.full_name"),
    );
  }
}
