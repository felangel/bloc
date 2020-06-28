import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_complex_list/bloc/list_bloc.dart';
import 'package:flutter_complex_list/models/models.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_complex_list/simple_bloc_observer.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Complex List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Complex List'),
        ),
        body: BlocProvider(
          create: (context) => ListBloc(repository: Repository())..add(Fetch()),
          child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListBloc, ListState>(
      builder: (context, state) {
        if (state is Failure) {
          return Center(
            child: Text('Oops something went wrong!'),
          );
        }
        if (state is Loaded) {
          if (state.items.isEmpty) {
            return Center(
              child: Text('no content'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ItemTile(
                item: state.items[index],
                onDeletePressed: (id) {
                  BlocProvider.of<ListBloc>(context).add(Delete(id: id));
                },
              );
            },
            itemCount: state.items.length,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ItemTile extends StatelessWidget {
  final Item item;
  final Function(String) onDeletePressed;

  const ItemTile({
    Key key,
    @required this.item,
    @required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('#${item.id}'),
      title: Text(item.value),
      trailing: item.isDeleting
          ? CircularProgressIndicator()
          : IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDeletePressed(item.id),
            ),
    );
  }
}
