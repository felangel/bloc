import 'package:flutter/material.dart';
import 'package:todos_api/todos_api.dart';

class TodoListTile extends StatelessWidget {
  const TodoListTile({
    Key? key,
    required this.todo,
    this.onToggleCompleted,
    this.onDismissed,
    this.onTap,
  }) : super(key: key);

  final Todo todo;
  final ValueChanged<bool>? onToggleCompleted;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todoListTile_dismissible_${todo.id}'),
      onDismissed: onDismissed == null ? null : (_) => onDismissed!(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: ListTile(
        title: Text(
          todo.title,
          maxLines: 1,
        ),
        subtitle: Text(
          todo.description,
          maxLines: 1,
        ),
        leading: Checkbox(
          value: todo.completed,
          onChanged: onToggleCompleted == null
              ? null
              : (value) => onToggleCompleted!(value!),
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
