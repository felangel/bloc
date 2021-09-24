import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';
import 'package:flutter_firestore_todos/screens/screens.dart';
import 'package:flutter_firestore_todos/widgets/widgets.dart';

class FilteredTodos extends StatelessWidget {
  FilteredTodos({Key? key}) : super(key: key);

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
                  context.read<TodosBloc>().add(DeleteTodo(todo));
                  ScaffoldMessenger.of(context).showSnackBar(
                    DeleteTodoSnackBar(
                      todo: todo,
                      onUndo: () {
                        context.read<TodosBloc>().add(AddTodo(todo));
                      },
                    ),
                  );
                },
                onTap: () async {
                  final removedTodo = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) {
                      return DetailsScreen(id: todo.id);
                    }),
                  );
                  if (removedTodo != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      DeleteTodoSnackBar(
                        todo: todo,
                        onUndo: () {
                          context.read<TodosBloc>().add(AddTodo(todo));
                        },
                      ),
                    );
                  }
                },
                onCheckboxChanged: (_) {
                  context
                      .read<TodosBloc>()
                      .add(UpdateTodo(todo.copyWith(complete: !todo.complete)));
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
