import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firestore_todos/blocs/todos/todos.dart';
import 'package:flutter_firestore_todos/models/models.dart';

class ExtraActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        if (state is TodosLoaded) {
          final allComplete = state.todos.every((todo) => todo.complete);
          return PopupMenuButton<ExtraAction>(
            onSelected: (action) {
              switch (action) {
                case ExtraAction.clearCompleted:
                  context.read<TodosBloc>().add(ClearCompleted());
                  break;
                case ExtraAction.toggleAllComplete:
                  context.read<TodosBloc>().add(ToggleAll());
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuItem<ExtraAction>>[
              PopupMenuItem<ExtraAction>(
                value: ExtraAction.toggleAllComplete,
                child: Text(
                  allComplete ? 'Mark all incomplete' : 'Mark all complete',
                ),
              ),
              PopupMenuItem<ExtraAction>(
                value: ExtraAction.clearCompleted,
                child: Text('Clear completed'),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
