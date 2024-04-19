import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/stats/riverpod/stats_notifier.dart';
import 'package:flutter_todos/stats/riverpod/stats_state.dart';

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(statsNotifierProvider.notifier).fetchStats(),
    );

    final l10n = context.l10n;
    final state = ref.watch(statsNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsAppBarTitle),
      ),
      body: Column(
        children: [
          if (state.status == StatsStatus.loading)
            const CircularProgressIndicator(),
          if (state.status == StatsStatus.success) ...[
            ListTile(
              key: const Key('statsView_completedTodos_listTile'),
              leading: const Icon(Icons.check_rounded),
              title: Text(l10n.statsCompletedTodoCountLabel),
              trailing: Text(
                '${state.completedTodos}',
                style: textTheme.headlineSmall,
              ),
            ),
            ListTile(
              key: const Key('statsView_activeTodos_listTile'),
              leading: const Icon(Icons.radio_button_unchecked_rounded),
              title: Text(l10n.statsActiveTodoCountLabel),
              trailing: Text(
                '${state.activeTodos}',
                style: textTheme.headlineSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
