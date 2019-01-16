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
        body: SearchForm(
          githubSearchBloc: GithubSearchBloc(
              GithubService(GithubCache(), GithubClient(http.Client()))),
        ),
      ),
    );
  }
}

// Define a Custom Form Widget
class SearchForm extends StatefulWidget {
  final GithubSearchBloc githubSearchBloc;
  SearchForm({
    Key key,
    @required this.githubSearchBloc,
  }) : super(key: key);
  @override
  _SearchFormState createState() => _SearchFormState();
}

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _SearchFormState extends State<SearchForm> {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  // _SearchFormState() {
  //   _textController.addListener(_onTextChanged(""));
  //   //_githubSearchBloc.dispatch(TextChanged());
  // }

  @override
  void initState() {
    _githubSearchBloc = widget.githubSearchBloc;
    // _textController.addListener(_onTextChanged(""));
    _githubSearchBloc.onTextChanged("");
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    _textController.dispose();
    _githubSearchBloc.dispose();
    super.dispose();
  }

  _onTextChanged() {
    _githubSearchBloc.onTextChanged(_textController.text);
    //_textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    //return scaffold appbar
    return BlocBuilder<GithubSearchEvent, GithubSearchState>(
      bloc: widget.githubSearchBloc,
      builder: (BuildContext context, GithubSearchState state) {
        print(state);
        if (state.noTerm) {
          return TextField(
            controller: _textController,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please enter a search term'),
          );
        }
        if (state.isLoading) {
          return _buildTextField(
              state: state,
              child: Center(
                child: CircularProgressIndicator(),
              ));
        }

        if (!state.result.isPopulated) {
          return _buildTextField(
            state: state,
            child: Text("No results"),
          );
        }

        if (state.isError) {
          return _buildTextField(
              state: state, child: Text("Error: Rate Limit Exceeded"));
        }

        if (state.result.isPopulated) {
          return _buildTextField(
              state: state,
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

  Widget _buildTextField({Widget child, GithubSearchState state}) {
    print(state.result.items);
    return Row(
      children: <Widget>[
        TextField(
          controller: _textController,
          onChanged: _onTextChanged(),
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Please enter a search term'),
        ),
        child,
      ],
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
        child: Image.network(item?.owner.avatar_url),
      ),
      title: Text(item.full_name),
    );
  }
}
