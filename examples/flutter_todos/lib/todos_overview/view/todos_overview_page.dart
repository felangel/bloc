import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodosOverviewBloc(
        todosRepository: context.read<TodosRepository>(),
      )..add(const TodosOverviewSubscriptionRequested()),
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton()
        ],
      ),
      floatingActionButton: const AddTodoButton(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(l10n.todosOverviewErrorSnackbarText),
                  ));
              }
            },
          ),
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              final deletedTodo = state.lastDeletedTodo!;

              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(TodoDeletionConfirmationSnackBar(
                  todo: deletedTodo,
                  onUndo: () {
                    messenger.hideCurrentSnackBar();
                    context
                        .read<TodosOverviewBloc>()
                        .add(const TodosOverviewUndoDeletionRequested());
                  },
                ));
            },
          ),
        ],
        child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
          builder: (context, state) {
            if (state.todos.isEmpty) {
              if (state.status == TodosOverviewStatus.loading) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (state.status != TodosOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    l10n.todosOverviewEmptyText,
                    style: Theme.of(context).textTheme.caption,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView(
                children: [
                  for (final todo in state.filteredTodos)
                    TodoListTile(
                      todo: todo,
                      onToggleCompleted: (isCompleted) {
                        context
                            .read<TodosOverviewBloc>()
                            .add(TodosOverviewTodoCompletionToggled(
                              todo: todo,
                              isCompleted: isCompleted,
                            ));
                      },
                      onDismissed: () {
                        context
                            .read<TodosOverviewBloc>()
                            .add(TodosOverviewTodoDeleted(todo));
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddTodoButton extends StatelessWidget {
  const AddTodoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      onPressed: () {
        final todo = Todo(
          id: DateTime.now().toIso8601String(),
          title: ([
            'Foo',
            'Bar',
            'Baz',
            'Quux',
            'Xyzzy',
            'Plugh',
            'Bletch',
          ]..shuffle())
              .first,
          description:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
              'sed do eiusmod tempor incididunt ut labore et dolore magna '
              'aliqua. Ut enim ad minim veniam, quis nostrud exercitation '
              'ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        );
        context.read<TodosOverviewBloc>().add(TodosOverviewTodoSaved(todo));
      },
      child: const Icon(Icons.add),
    );
  }
}
