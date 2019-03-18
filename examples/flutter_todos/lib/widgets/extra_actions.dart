import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:flutter_todos/flutter_todos_keys.dart';

class ExtraActions extends StatelessWidget {
  ExtraActions({Key key}) : super(key: ArchSampleKeys.extraActionsButton);

  @override
  Widget build(BuildContext context) {
    final todosBloc = BlocProvider.of<TodosBloc>(context);
    return BlocBuilder(
      bloc: todosBloc,
      builder: (BuildContext context, TodosState state) {
        if (state is TodosLoaded) {
          bool allComplete = (todosBloc.currentState as TodosLoaded)
              .todos
              .every((todo) => todo.complete);
          return PopupMenuButton<ExtraAction>(
            key: FlutterTodosKeys.extraActionsPopupMenuButton,
            onSelected: (action) {
              switch (action) {
                case ExtraAction.clearCompleted:
                  todosBloc.dispatch(ClearCompleted());
                  break;
                case ExtraAction.toggleAllComplete:
                  todosBloc.dispatch(ToggleAll());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<ExtraAction>>[
                  PopupMenuItem<ExtraAction>(
                    key: ArchSampleKeys.toggleAll,
                    value: ExtraAction.toggleAllComplete,
                    child: Text(
                      allComplete
                          ? ArchSampleLocalizations.of(context)
                              .markAllIncomplete
                          : ArchSampleLocalizations.of(context).markAllComplete,
                    ),
                  ),
                  PopupMenuItem<ExtraAction>(
                    key: ArchSampleKeys.clearCompleted,
                    value: ExtraAction.clearCompleted,
                    child: Text(
                      ArchSampleLocalizations.of(context).clearCompleted,
                    ),
                  ),
                ],
          );
        }
        return Container(key: FlutterTodosKeys.extraActionsEmptyContainer);
      },
    );
  }
}
