import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:flutter_todos/l10n/l10n.dart';

class TodosOverviewFilterButton extends StatelessWidget {
  const TodosOverviewFilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final activeFilter =
        context.select((TodosOverviewBloc bloc) => bloc.state.filter);
    final activeColor = Theme.of(context).accentColor;

    return PopupMenuButton<TodosViewFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeFilter,
      tooltip: l10n.todosOverviewFilterTooltip,
      onSelected: (filter) {
        context
            .read<TodosOverviewBloc>()
            .add(TodosOverviewFilterChanged(filter));
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosViewFilter.all,
            child: Text(
              l10n.todosOverviewFilterAll,
              style: activeFilter != TodosViewFilter.all
                  ? null
                  : TextStyle(color: activeColor),
            ),
          ),
          PopupMenuItem(
            value: TodosViewFilter.activeOnly,
            child: Text(
              l10n.todosOverviewFilterActiveOnly,
              style: activeFilter != TodosViewFilter.activeOnly
                  ? null
                  : TextStyle(color: activeColor),
            ),
          ),
          PopupMenuItem(
            value: TodosViewFilter.completedOnly,
            child: Text(
              l10n.todosOverviewFilterCompletedOnly,
              style: activeFilter != TodosViewFilter.completedOnly
                  ? null
                  : TextStyle(color: activeColor),
            ),
          ),
        ];
      },
      child: const Icon(Icons.filter_list_rounded),
    );
  }
}
