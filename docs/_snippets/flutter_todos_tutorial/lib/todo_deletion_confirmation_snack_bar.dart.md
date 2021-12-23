```dart
import 'package:flutter/material.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoDeletionConfirmationSnackBar extends SnackBar {
  TodoDeletionConfirmationSnackBar({
    Key? key,
    required Todo todo,
    required VoidCallback onUndo,
  }) : super(
          key: key,
          content: TodoDeletionConfirmationSnackBarContent(
            todo: todo,
            onUndo: onUndo,
          ),
        );
}

@visibleForTesting
class TodoDeletionConfirmationSnackBarContent extends StatelessWidget {
  const TodoDeletionConfirmationSnackBarContent({
    Key? key,
    required this.todo,
    required this.onUndo,
  }) : super(key: key);

  final Todo todo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.todosOverviewTodoDeletedSnackbarText(todo.title),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onUndo,
          child: Text(l10n.todosOverviewUndoDeletionButtonText),
        ),
      ],
    );
  }
}

```