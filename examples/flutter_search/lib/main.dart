import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
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
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final _textController = TextEditingController();

  final GithubSearchBloc _githubSearchBloc = GithubSearchBloc(
      GithubService(GithubCache(), GithubClient(http.Client())));

  _SearchFormState() {
    _githubSearchBloc.dispatch(TextChanged(text: ""));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    _githubSearchBloc.dispose();
    super.dispose();
  }

  // _onTextChanged() {
  //   final text = _textController.text;
  //   _githubSearchBloc.dispatch(TextChanged(text: text));
  // }

  @override
  Widget build(BuildContext context) {
    TextField textField = TextField(
      controller: _textController,
      onChanged: (text) {
        _githubSearchBloc.dispatch(TextChanged(text: text));
      },
      decoration: InputDecoration(
          border: InputBorder.none, hintText: 'Please enter a search term'),
    );

    return BlocBuilder<GithubSearchEvent, GithubSearchState>(
      bloc: _githubSearchBloc,
      builder: (BuildContext context, GithubSearchState state) {
        if (state.noTerm) {
          return textField;
        }
        if (state.isLoading) {
          return _buildTextFieldChild(
              textField: textField,
              child: Center(
                child: CircularProgressIndicator(),
              ));
        }

        if (!state.result.isPopulated) {
          return _buildTextFieldChild(
            textField: textField,
            child: Text("No results"),
          );
        }

        if (state.isError) {
          return _buildTextFieldChild(
              textField: textField, child: Text("Error: Rate Limit Exceeded"));
        }

        if (state.result.isPopulated) {
          return _buildTextFieldChild(
              textField: textField,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return index <= state.result.items.length
                      ? CircularProgressIndicator()
                      : SearchResultItemWidget(item: state.result.items[index]);
                },
                itemCount: state.result.items.length,
              ));
        }
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
        child: Image.network(item?.owner.avatar_url),
      ),
      title: Text(item.full_name),
    );
  }
}
