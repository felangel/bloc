import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';
import 'package:flutter_firestore_todos/widgets/widgets.dart';
import 'package:flutter_firestore_todos/screens/screens.dart';

class FilteredTodos extends StatelessWidget {
  FilteredTodos({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilteredTodosBloc, FilteredTodosState>(
      builder: (context, state) {
        if (state is FilteredTodosLoading) {
          return LoadingIndicator();
        } else if (state is FilteredTodosLoaded) {
          final todos = state.filteredTodos;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoItem(
                todo: todo,
                onDismissed: (direction) {
                  BlocProvider.of<TodosBloc>(context).add(DeleteTodo(todo));
                  Scaffold.of(context).showSnackBar(DeleteTodoSnackBar(
                    todo: todo,
                    onUndo: () =>
                        BlocProvider.of<TodosBloc>(context).add(AddTodo(todo)),
                  ));
                },
                onTap: () async {
                  final removedTodo = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) {
                      return DetailsScreen(id: todo.id);
                    }),
                  );
                  if (removedTodo != null) {
                    Scaffold.of(context).showSnackBar(
                      DeleteTodoSnackBar(
                        todo: todo,
                        onUndo: () => BlocProvider.of<TodosBloc>(context)
                            .add(AddTodo(todo)),
                      ),
                    );
                  }
                },
                onCheckboxChanged: (_) {
                  BlocProvider.of<TodosBloc>(context).add(
                    UpdateTodo(todo.copyWith(complete: !todo.complete)),
                  );
                },
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
