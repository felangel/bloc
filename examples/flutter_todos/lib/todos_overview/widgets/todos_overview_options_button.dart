import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/riverpod/todos_overview_notifier.dart';

enum TodosOverviewOption { toggleAll, clearCompleted }

class TodosOverviewOptionsButton extends ConsumerWidget {
  const TodosOverviewOptionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final todosOverviewState = ref.watch(todosOverviewNotifierProvider);
    final todos = todosOverviewState.todos;
    final hasTodos = todos.isNotEmpty;
    final completedTodosAmount = todos.where((todo) => todo.isCompleted).length;
    final notifier = ref.read(todosOverviewNotifierProvider.notifier);

    return PopupMenuButton<TodosOverviewOption>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      tooltip: l10n.todosOverviewOptionsTooltip,
      onSelected: (option) {
        if (option == TodosOverviewOption.toggleAll) {
          notifier.toggleAll();
        } else if (option == TodosOverviewOption.clearCompleted) {
          notifier.clearCompleted();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: TodosOverviewOption.toggleAll,
          enabled: hasTodos,
          child: Text(
            completedTodosAmount == todos.length
                ? l10n.todosOverviewOptionsMarkAllIncomplete
                : l10n.todosOverviewOptionsMarkAllComplete,
          ),
        ),
        PopupMenuItem(
          value: TodosOverviewOption.clearCompleted,
          enabled: hasTodos && completedTodosAmount > 0,
          child: Text(l10n.todosOverviewOptionsClearCompleted),
        ),
      ],
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}
