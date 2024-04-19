import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/edit_todo/view/edit_todo_page.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/riverpod/todos_overview_notifier.dart';
import 'package:flutter_todos/todos_overview/riverpod/todos_overview_state.dart';

import 'package:flutter_todos/todos_overview/widgets/todo_list_tile.dart';
import 'package:flutter_todos/todos_overview/widgets/todos_overview_filter_button.dart';
import 'package:flutter_todos/todos_overview/widgets/todos_overview_options_button.dart';

class TodosOverviewPage extends ConsumerWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(todosOverviewNotifierProvider.notifier).fetchTodos(),
    );

    return const TodosOverviewView();
  }
}

class TodosOverviewView extends ConsumerWidget {
  const TodosOverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(todosOverviewNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.todos.isEmpty) {
            if (state.status == TodosOverviewStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.status != TodosOverviewStatus.success) {
              return const SizedBox.shrink();
            } else {
              return Center(
                child: Text(
                  l10n.todosOverviewEmptyText,
                  style: Theme.of(context).textTheme.bodySmall,
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
                    onToggleCompleted: (isCompleted) => ref
                        .read(todosOverviewNotifierProvider.notifier)
                        .toggleCompletion(todo, isCompleted),
                    onDismissed: (_) => ref
                        .read(todosOverviewNotifierProvider.notifier)
                        .deleteTodo(todo),
                    onTap: () => Navigator.of(context).push(
                      EditTodoPage.route(initialTodo: todo),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
